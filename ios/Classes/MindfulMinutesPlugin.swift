import Flutter
import UIKit
import HealthKit

public class MindfulMinutesPlugin: NSObject, FlutterPlugin {
    
    let healthStore = HKHealthStore()
    let type = HKSampleType.categoryType(forIdentifier: .mindfulSession)!
    
    struct PluginError: Error {
        let message: String
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "mindful_minutes", binaryMessenger: registrar.messenger())
        let instance = MindfulMinutesPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "checkPermission":
            try! _checkPermission(call: call, result: result)
            break;
        case "requestPermission":
            try! _requestPermission(call: call, result: result)
            break;
        case "saveMindfulMinutes":
            try! _saveMindfulMinutes(call: call, result: result)
            break;
        default:
            break;
        }
    }
    
    func _checkPermission(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let status = healthStore.authorizationStatus(for: type)
        let granted = status == HKAuthorizationStatus.sharingAuthorized
        DispatchQueue.main.async {
            result(granted)
        }
    }
    
    func _requestPermission(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        healthStore.requestAuthorization(toShare: [type], read: nil) { (success, error) in
            DispatchQueue.main.async {
                result(success)
            }
        }
    }
    
    func _saveMindfulMinutes(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard let arguments = call.arguments as? NSDictionary,
              let startTime = arguments["startTime"] as? NSNumber,
              let endTime = arguments["endTime"] as? NSNumber
        else {
            throw PluginError(message: "Invalid Arguments")
        }
        
        let start = Date(timeIntervalSince1970: startTime.doubleValue / 1000)
        let end = Date(timeIntervalSince1970: endTime.doubleValue / 1000)
        let sample = HKCategorySample(type: type, value: 0, start: start, end: end)
        
        healthStore.save(sample, withCompletion: { (success, error) in
            if let err = error {
                print("Error saving \(self.type).")
                print("Sample: \(err.localizedDescription).")
            }
            DispatchQueue.main.async {
                result(success)
            }
        })
    }
}
