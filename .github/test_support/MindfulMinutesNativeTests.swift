import XCTest

import Flutter
import HealthKit

private final class FakeMindfulHealthStore: MindfulHealthStore {
  var status: HKAuthorizationStatus = .notDetermined
  var requestResult = true
  var requestError: Error?
  var saveResult = true
  var saveError: Error?
  var sharedTypes: Set<HKSampleType> = []
  var savedSamples: [HKCategorySample] = []

  func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus { status }

  func requestAuthorization(toShare types: Set<HKSampleType>, completion: @escaping (Bool, Error?) -> Void) {
    sharedTypes = types
    completion(requestResult, requestError)
  }

  func save(_ sample: HKCategorySample, completion: @escaping (Bool, Error?) -> Void) {
    savedSamples.append(sample)
    completion(saveResult, saveError)
  }
}

final class MindfulMinutesNativeTests: XCTestCase {
  private func invoke(_ plugin: MindfulMinutesPlugin, _ method: String, arguments: Any? = nil) -> Any? {
    let completed = expectation(description: method)
    var value: Any?
    plugin.handle(FlutterMethodCall(methodName: method, arguments: arguments)) {
      value = $0
      completed.fulfill()
    }
    wait(for: [completed], timeout: 2)
    return value
  }

  func testUnavailableHealthKitReturnsFalseForKnownMethods() {
    let plugin = MindfulMinutesPlugin(healthStore: nil)
    for method in ["checkPermission", "requestPermission", "saveMindfulMinutes"] {
      XCTAssertEqual(invoke(plugin, method) as? Bool, false)
    }
    XCTAssertTrue(invoke(plugin, "unknown") as AnyObject === FlutterMethodNotImplemented)
  }

  func testOnlySharingAuthorizedGrantsWritePermission() {
    let store = FakeMindfulHealthStore()
    let plugin = MindfulMinutesPlugin(healthStore: store)
    for status in [HKAuthorizationStatus.notDetermined, .sharingDenied, .sharingAuthorized] {
      store.status = status
      XCTAssertEqual(invoke(plugin, "checkPermission") as? Bool, status == .sharingAuthorized)
    }
  }

  func testPromptCompletionDoesNotImplyWritePermission() {
    let store = FakeMindfulHealthStore()
    store.status = .sharingDenied
    let plugin = MindfulMinutesPlugin(healthStore: store)
    XCTAssertEqual(invoke(plugin, "requestPermission") as? Bool, true)
    XCTAssertEqual(invoke(plugin, "checkPermission") as? Bool, false)
    XCTAssertEqual(store.sharedTypes, [HKObjectType.categoryType(forIdentifier: .mindfulSession)!])
  }

  func testPermissionErrorsAreReported() {
    let store = FakeMindfulHealthStore()
    store.requestError = NSError(domain: "test", code: 1)
    let error = invoke(MindfulMinutesPlugin(healthStore: store), "requestPermission") as? FlutterError
    XCTAssertEqual(error?.code, "PERMISSION_ERROR")
  }

  func testInvalidIntervalsNeverReachHealthKit() {
    let store = FakeMindfulHealthStore()
    let plugin = MindfulMinutesPlugin(healthStore: store)
    let invalid: [Any?] = [nil, ["startTime": "wrong", "endTime": 2],
      ["startTime": 2.0, "endTime": 1.0], ["startTime": Double.infinity, "endTime": 2.0],
      ["startTime": 1.0, "endTime": Double.nan]]
    for arguments in invalid {
      let error = invoke(plugin, "saveMindfulMinutes", arguments: arguments) as? FlutterError
      XCTAssertEqual(error?.code, "INVALID_ARGUMENTS")
    }
    XCTAssertTrue(store.savedSamples.isEmpty)
  }

  func testSaveConvertsMillisecondsAndPropagatesResults() {
    let store = FakeMindfulHealthStore()
    let plugin = MindfulMinutesPlugin(healthStore: store)
    let arguments = ["startTime": 1000, "endTime": 61000]
    XCTAssertEqual(invoke(plugin, "saveMindfulMinutes", arguments: arguments) as? Bool, true)
    XCTAssertEqual(store.savedSamples.first?.startDate.timeIntervalSince1970, 1)
    XCTAssertEqual(store.savedSamples.first?.endDate.timeIntervalSince1970, 61)
    XCTAssertEqual(store.savedSamples.first?.value, HKCategoryValue.notApplicable.rawValue)
    store.saveResult = false
    XCTAssertEqual(invoke(plugin, "saveMindfulMinutes", arguments: arguments) as? Bool, false)
    store.saveError = NSError(domain: "test", code: 2)
    let error = invoke(plugin, "saveMindfulMinutes", arguments: arguments) as? FlutterError
    XCTAssertEqual(error?.code, "SAVE_ERROR")
  }
}
