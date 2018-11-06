//
//  AppDelegate.swift
//  AnalysysSwiftDemo
//
//  Created by analysys on 2018/5/7.
//  Copyright © 2018年 analysys. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //  4.1.0 前版本初始化方式
        //        AnalysysAgent.start(withAppKey: "commondemo",
        //                             channel: "App Store",
        //                             baseURL: "sdk.analysys.cn")
        
        //  4.1.0 及之后版本初始化方式
        //  AnalysysAgent 配置信息
        AnalysysAgentConfig.shareInstance().appKey = "commondemo"
        AnalysysAgentConfig.shareInstance().channel = "App Store"
        AnalysysAgentConfig.shareInstance().baseUrl = "sdk.analysys.cn"
        AnalysysAgentConfig.shareInstance().autoProfile = true
        AnalysysAgentConfig.shareInstance().encryptType = .AES
        //  使用配置信息初始化SDK
        AnalysysAgent.start(with: AnalysysAgentConfig.shareInstance())
        
        AnalysysAgent.setDebugMode(.butTrack)
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

