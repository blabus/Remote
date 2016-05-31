//
//  AppDelegate.swift
//  Remote
//
//  Created by Bill Labus on 4/25/16.
//  Copyright © 2016 Bill Labus. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
		let sourceViewController = SourceViewController(nibName: "SourceViewController", bundle: nil)
		window?.rootViewController = sourceViewController
		self.window?.makeKeyAndVisible()
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		ControlAPI.sharedInstance.stopUpdatingState()
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		ControlAPI.sharedInstance.startUpdatingState()
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
}