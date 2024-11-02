import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Read API key from Info.plist
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "MAPS_API_KEY") as? String {
            GMSServices.provideAPIKey(apiKey)
            print("Google Maps initialized with API key from environment")
        } else {
            print("Warning: MAPS_API_KEY not found in environment")
        }
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "com.example.app/environment",
                                         binaryMessenger: controller.binaryMessenger)
        
        channel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
            case "getApiKey":
                let apiKey = Bundle.main.object(forInfoDictionaryKey: "MAPS_API_KEY") as? String
                result(apiKey)
            case "initGoogleMaps":
                // API key is already initialized in application launch
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}