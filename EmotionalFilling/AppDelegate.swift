//
//  AppDelegate.swift
//  EmotionalFilling
//
//  Created by Роман Главацкий on 09.10.2025.
//

import UIKit
import AppsFlyerLib

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var restrictRotation: UIInterfaceOrientationMask = .all
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // AppsFlyer Init
           AppsFlyerLib.shared().appsFlyerDevKey = "toyM7kSMwKPbxp7pjaykqG"
           AppsFlyerLib.shared().appleAppID = "6752398061"
           AppsFlyerLib.shared().delegate = self
           AppsFlyerLib.shared().isDebug = true
           
        AppsFlyerLib.shared().start()
        let appsFlyerId = AppsFlyerLib.shared().getAppsFlyerUID()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ data: [AnyHashable : Any]) {
         var finalURL = ""
        let appsflyerID = AppsFlyerLib.shared().getAppsFlyerUID()
            print("📬 Conversion: \(data)")
            if let dict = data as? [String: Any], let campaign = dict["campaign"] as? String {
                let extra = campaign
                    .components(separatedBy: "||")
                    .compactMap { pair -> String? in
                        let p = pair.split(separator: "="); guard p.count == 2 else { return nil }
                        return "&\(p[0])=\(p[1])"
                    }
                    .joined()
                print("Extra = \(extra)")
               finalURL += "appsflyer_id=\(appsflyerID)\(extra)"
            } else {
                print("Organic")
                finalURL += "appsflyer_id=\(appsflyerID)&source=organic"
            }
        print("Final URL: \(finalURL)")
        UserDefaults.standard.set(finalURL, forKey: "finalAppsflyerURL")
        NotificationCenter.default.post(name: Notification.Name("AppsFlyerDataReceived"), object: nil)
        }

    func onConversionDataFail(_ error: Error) {
        print("❌ Conversion data error: \(error.localizedDescription)")
    }
}
