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
      LiveActivityController.shared.start(
        pursuitName: name,
        pursuitColorARGB: argb,
        effectiveStartedAt: Date(timeIntervalSince1970: startedAtMs.doubleValue / 1000.0)
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
          pausedAtFreezeSeconds: freeze.intValue
        )
        result(nil)
      }
    case "end":
      Task {
        await LiveActivityController.shared.end()
        result(nil)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
