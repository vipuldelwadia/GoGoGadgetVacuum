//
//  AppDelegate.swift
//  GoGoGadgetVacuum
//
//  Created by Vipul Delwadia on 20/07/19.
//  Copyright © 2019 Vipul Delwadia. All rights reserved.
//

import MultipeerKit

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIView.appearance().tintColor = .orange

        // fire up the store
        _ = Store.shared

        // fire up the multipeer manager
        MultipeerManager.shared.resume()

        return true
    }
}

