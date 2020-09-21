//
//  AppDelegate.swift
//  GoGoGadgetVacuum
//
//  Created by Vipul Delwadia on 20/07/19.
//  Copyright © 2019 Vipul Delwadia. All rights reserved.
//

import CloudKit
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        UIView.appearance().tintColor = .orange

//        UIApplication.shared.registerForRemoteNotifications()

        // fire up the store
        _ = Store.shared

        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if let notification = CKNotification(fromRemoteNotificationDictionary: userInfo),
            notification.notificationType == .query,
            let queryNotification = notification as? CKQueryNotification,
            let recordID = queryNotification.recordID {
            Store.shared.updateFromCloudKit(with: recordID)
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }

        if aps["content-available"] as? Int == 1,
            let commandValue = userInfo["command"] as? String,
            let command = Command(rawValue: commandValue) {
            // do things here
            AudioPlayer.shared.handleCommand(command)
        }

        completionHandler(.noData)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token:", token)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register:", error)
    }
}

