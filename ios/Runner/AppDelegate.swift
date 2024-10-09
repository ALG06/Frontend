import Flutter
import UIKit
import GoogleMaps
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "com.example.app/environment",
                                           binaryMessenger: controller.binaryMessenger)
                var googleMapsInitialized = false
        
        channel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "getApiKey" {
                // This will be implemented in Dart
                result(nil)
            } else if call.method == "initGoogleMaps" {
                if let apiKey = call.arguments as? String {
                    if !googleMapsInitialized {
                        GMSServices.provideAPIKey(apiKey)
                        googleMapsInitialized = true
                        print("Google Maps initialized with API key")
                    }
                    result(true)
                } else {
                    print("Error: Failed to get MAPS_API_KEY from Flutter")
                    result(FlutterError(code: "INVALID_API_KEY", message: "API key is null or invalid", details: nil))
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        })


    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
