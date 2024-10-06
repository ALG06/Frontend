import Flutter
import UIKit
import GoogleMaps
import Dotenv


@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    Dotenv.load()

    if let apiKey = Dotenv.get("MAPS_API_KEY") {
      GMSServices.provideAPIKey(apiKey)
    } else {
      print("Error: MAPS_API_KEY not found in environment variables")
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
