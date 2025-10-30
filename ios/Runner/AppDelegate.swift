import Flutter
import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    // Configure reCAPTCHA for phone auth
    #if targetEnvironment(simulator)
    Auth.auth().settings?.isAppVerificationDisabledForTesting = true
    #else
    Auth.auth().settings?.isAppVerificationDisabledForTesting = false
    #endif
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(_ app: UIApplication,
                          open url: URL,
                          options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // Handle Google Sign-In
    if GIDSignIn.sharedInstance.handle(url) {
      return true
    }
    
    // Handle Firebase Auth
    if Auth.auth().canHandle(url) {
      return true
    }
    
    return super.application(app, open: url, options: options)
  }
  
  override func application(_ application: UIApplication,
                          continue userActivity: NSUserActivity,
                          restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if let incomingURL = userActivity.webpageURL {
      let linkHandled = Auth.auth().canHandle(incomingURL)
      if linkHandled {
        return true
      }
    }
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }
}
