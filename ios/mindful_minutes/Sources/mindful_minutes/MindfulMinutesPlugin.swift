import CoreFoundation
import Flutter
import HealthKit

protocol MindfulHealthStore {
  func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus
  func requestAuthorization(toShare types: Set<HKSampleType>, completion: @escaping (Bool, Error?) -> Void)
  func save(_ sample: HKCategorySample, completion: @escaping (Bool, Error?) -> Void)
}

private struct SystemMindfulHealthStore: MindfulHealthStore {
  private let store = HKHealthStore()

  func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus {
    store.authorizationStatus(for: type)
  }

  func requestAuthorization(toShare types: Set<HKSampleType>, completion: @escaping (Bool, Error?) -> Void) {
    store.requestAuthorization(toShare: types, read: nil, completion: completion)
  }

  func save(_ sample: HKCategorySample, completion: @escaping (Bool, Error?) -> Void) {
    store.save(sample, withCompletion: completion)
  }
}

public class MindfulMinutesPlugin: NSObject, FlutterPlugin {

  private let healthStore: MindfulHealthStore?

  public override convenience init() {
    self.init(healthStore: HKHealthStore.isHealthDataAvailable() ? SystemMindfulHealthStore() : nil)
  }

  init(healthStore: MindfulHealthStore?) {
    self.healthStore = healthStore
    super.init()
  }
  let type = HKSampleType.categoryType(forIdentifier: .mindfulSession)!

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "mindful_minutes", binaryMessenger: registrar.messenger())
    let instance = MindfulMinutesPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "checkPermission", "requestPermission", "saveMindfulMinutes":
      guard let healthStore = healthStore else {
        result(false)
        return
      }
      switch call.method {
      case "checkPermission":
        checkPermission(healthStore: healthStore, result: result)
      case "requestPermission":
        requestPermission(healthStore: healthStore, result: result)
      default:
        saveMindfulMinutes(call: call, healthStore: healthStore, result: result)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // Function to check if permission has been granted for the app to write to HealthKit
  private func checkPermission(healthStore: MindfulHealthStore, result: @escaping FlutterResult) {
    let status = healthStore.authorizationStatus(for: type)
    let granted = status == HKAuthorizationStatus.sharingAuthorized
    DispatchQueue.main.async {
      result(granted)
    }
  }

  // Function to request permission from the user to write to HealthKit
  private func requestPermission(healthStore: MindfulHealthStore, result: @escaping FlutterResult) {
    healthStore.requestAuthorization(toShare: [type]) { (success, error) in
      if let error = error {
        DispatchQueue.main.async {
          result(FlutterError(code: "PERMISSION_ERROR", message: error.localizedDescription, details: nil))
        }
        return
      }
      DispatchQueue.main.async {
        result(success)
      }
    }
  }

  // Function to save mindful minutes to HealthKit
  private func saveMindfulMinutes(call: FlutterMethodCall, healthStore: MindfulHealthStore, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? NSDictionary,
          let startTime = arguments["startTime"] as? NSNumber,
          let endTime = arguments["endTime"] as? NSNumber,
          CFGetTypeID(startTime) != CFBooleanGetTypeID(),
          CFGetTypeID(endTime) != CFBooleanGetTypeID() else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for saveMindfulMinutes", details: nil))
        return
    }

    let startTimestamp = startTime.doubleValue
    let endTimestamp = endTime.doubleValue
    guard startTimestamp.isFinite, endTimestamp.isFinite, endTimestamp >= startTimestamp else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected finite timestamps with endTime at or after startTime", details: nil))
      return
    }

    let start = Date(timeIntervalSince1970: startTimestamp / 1000)
    let end = Date(timeIntervalSince1970: endTimestamp / 1000)
    let sample = HKCategorySample(type: type, value: 0, start: start, end: end)

    healthStore.save(sample) { (success, error) in
      if let error = error {
        DispatchQueue.main.async {
          result(FlutterError(code: "SAVE_ERROR", message: "Error saving \(self.type): \(error.localizedDescription)", details: nil))
        }
        return
      }
      DispatchQueue.main.async {
        result(success)
      }
    }
  }
}
