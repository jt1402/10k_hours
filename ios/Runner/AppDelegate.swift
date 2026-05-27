import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerLiveActivityChannel(engineBridge: engineBridge)
    registerGoalAlarmChannel(engineBridge: engineBridge)
  }

  private func registerGoalAlarmChannel(engineBridge: FlutterImplicitEngineBridge) {
    let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "GoalAlarmBridge")!
    let channel = FlutterMethodChannel(
      name: "ten_k_hours/goal_alarm",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      AppDelegate.handleGoalAlarmCall(call, result: result)
    }
  }

  static func handleGoalAlarmCall(
    _ call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    #if canImport(AlarmKit)
    guard #available(iOS 26.0, *) else {
      result(nil) // AlarmKit needs iOS 26 — older OS silently no-ops
      return
    }
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "schedule":
      guard
        let fireAtMs = args["fireAtMs"] as? NSNumber,
        let name = args["pursuitName"] as? String,
        let argb = args["pursuitColorARGB"] as? Int
      else {
        result(FlutterError(code: "BAD_ARGS", message: "missing args for schedule", details: nil))
        return
      }
      let fireAt = Date(timeIntervalSince1970: fireAtMs.doubleValue / 1000.0)
      Task {
        await AlarmController.shared.schedule(
          fireAt: fireAt,
          pursuitName: name,
          colorARGB: argb
        )
        result(nil)
      }
    case "cancel":
      Task {
        await AlarmController.shared.cancel()
        result(nil)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
    #else
    result(nil) // SDK without AlarmKit — no-op
    #endif
  }

  private func registerLiveActivityChannel(engineBridge: FlutterImplicitEngineBridge) {
    let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "LiveActivityBridge")!
    let channel = FlutterMethodChannel(
      name: "ten_k_hours/live_activity",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      AppDelegate.handleLiveActivityCall(call, result: result)
    }
  }

  static func handleLiveActivityCall(
    _ call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    guard #available(iOS 16.2, *) else {
      result(nil) // older OS: silently no-op so Flutter can still call the API
      return
    }
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "start":
      guard
        let name = args["pursuitName"] as? String,
        let argb = args["pursuitColorARGB"] as? Int,
        let startedAtMs = args["effectiveStartedAtMs"] as? NSNumber
      else {
        result(FlutterError(code: "BAD_ARGS", message: "missing args for start", details: nil))
        return
      }
      let targetEndAt = (args["targetEndAtMs"] as? NSNumber).map {
        Date(timeIntervalSince1970: $0.doubleValue / 1000.0)
      }
      LiveActivityController.shared.start(
        pursuitName: name,
        pursuitColorARGB: argb,
        effectiveStartedAt: Date(timeIntervalSince1970: startedAtMs.doubleValue / 1000.0),
        displayText: args["displayText"] as? String,
        targetEndAt: targetEndAt
      )
      result(nil)
    case "update":
      guard
        let startedAtMs = args["effectiveStartedAtMs"] as? NSNumber,
        let isPaused = args["isPaused"] as? Bool,
        let freeze = args["pausedAtFreezeSeconds"] as? NSNumber
      else {
        result(FlutterError(code: "BAD_ARGS", message: "missing args for update", details: nil))
        return
      }
      Task {
        await LiveActivityController.shared.update(
          effectiveStartedAt: Date(timeIntervalSince1970: startedAtMs.doubleValue / 1000.0),
          isPaused: isPaused,
          pausedAtFreezeSeconds: freeze.intValue,
          displayText: args["displayText"] as? String
        )
        result(nil)
      }
    case "end":
      let finished = (args["finished"] as? Bool) ?? false
      Task {
        await LiveActivityController.shared.end(finished: finished)
        result(nil)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
