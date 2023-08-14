import Flutter
import HealthKit

public class MindfulMinutesPlugin: NSObject, FlutterPlugin {

  let healthStore = HKHealthStore()
  let type = HKSampleType.categoryType(forIdentifier: .mindfulSession)!

  public static func register(with registrar: FlutterPluginRegistrar) {
    // Check if HealthKit is available on the device
    if !HKHealthStore.isHealthDataAvailable() {
      print("HealthKit is not available on this device.")
      return
    }

    let channel = FlutterMethodChannel(name: "mindful_minutes", binaryMessenger: registrar.messenger())
    let instance = MindfulMinutesPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "checkPermission":
      checkPermission(call: call, result: result)
    case "requestPermission":
      requestPermission(call: call, result: result)
    case "saveMindfulMinutes":
      saveMindfulMinutes(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // Function to check if permission has been granted for the app to write to HealthKit
  private func checkPermission(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let status = healthStore.authorizationStatus(for: type)
    let granted = status == HKAuthorizationStatus.sharingAuthorized
    DispatchQueue.main.async {
      result(granted)
    }
  }

  // Function to request permission from the user to write to HealthKit
  private func requestPermission(call: FlutterMethodCall, result: @escaping FlutterResult) {
    healthStore.requestAuthorization(toShare: [type], read: nil) { (success, error) in
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
  private func saveMindfulMinutes(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? NSDictionary,
          let startTime = arguments["startTime"] as? NSNumber,
          let endTime = arguments["endTime"] as? NSNumber else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for saveMindfulMinutes", details: nil))
        return
    }

    let start = Date(timeIntervalSince1970: startTime.doubleValue / 1000)
    let end = Date(timeIntervalSince1970: endTime.doubleValue / 1000)
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
