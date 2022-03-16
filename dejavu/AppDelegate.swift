//
//  AppDelegate.swift
//  dejavu
//
//  Created by thongvm on 15/03/2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UILabel.appearance().adjustsFontForContentSizeCategory = false
        return true
    }

}

