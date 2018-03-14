//
//  AppDelegate.swift
//  CoreML_test
//
//  Created by Осина П.М. on 13.02.18.
//  Copyright © 2018 Осина П.М. All rights reserved.
//

import UIKit
import DITranquillity
import SVProgressHUD
import UserNotifications
import SafariServices


fileprivate let viewActionIdentifier = "VIEW_IDENTIFIER"
fileprivate let newsCategoryIdentifier = "NEWS_CATEGORY"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var container: DIContainer!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupAppearence()
        configureSVProgrssHUD()
        buildDependencyComponent()
        setupRootViewController()
        registerForPushNotifications()
        
        UNUserNotificationCenter.current().delegate = self

        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject]{
            let aps = notification["aps"] as? [String: AnyObject]
            _ = NewsItem.makeNewsItem(aps!)
            let notificationViewController = *container as NotificationViewController
            let navigationController = UINavigationController(rootViewController: notificationViewController)
            window!.rootViewController = navigationController

        }
        return true
        
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map{ data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error){
        print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let aps = userInfo["aps"] as! [String: AnyObject]
        _ = NewsItem.makeNewsItem(aps)
        if aps["content-available"] as? Int == 1{

        }else{
            _ = NewsItem.makeNewsItem(aps)
            completionHandler(.newData)
        }
        
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

    private func buildDependencyComponent(){
        container = DIContainer()
        container.append(part: AppDIPart.self)
        container.append(part: NetworkDIPart.self)
        container.append(part: MainDIPart.self)
        container.append(part: TextDetectorDIPart.self)
        container.append(part: MapDIPart.self)
        container.append(part: NotificationDIPart.self)
        container.append(part: LocalNotificationDIPart.self)
        if !container.validate(){
            fatalError("DI fatal error")
        }
    }
    
    func registerForPushNotifications(){
        
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (permissionGranted, error) in
//            
//            //3 - Handle your error
//            print(error as Any)
//        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            print("Permission granted: \(granted)")

            guard granted else { return }

            let viewAction = UNNotificationAction(identifier: viewActionIdentifier,
                                                  title: "View", options: [.foreground])
            let newsCategoty = UNNotificationCategory(identifier: newsCategoryIdentifier,
                                                      actions: [viewAction],
                                                      intentIdentifiers: [],
                                                      options: [])
            UNUserNotificationCenter.current().setNotificationCategories([newsCategoty])
            self.getNotificationSettings()
        }
    }

    func getNotificationSettings(){
        UNUserNotificationCenter.current().getNotificationSettings{ (settings) in
            print("Notification settings: \(settings)")

            guard settings.authorizationStatus == .authorized else {return}
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
   
    private func setupAppearence(){
        UINavigationBar.appearance().backIndicatorImage = #imageLiteral(resourceName: "back_button_gray").withRenderingMode(.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "back_button_gray")
    }
    
    private func configureSVProgrssHUD(){
        SVProgressHUD.setMaximumDismissTimeInterval(1.3)
    }
    
    func setupRootViewController(){
        let mainViewController = *container as MainViewController
        let navigationController = UINavigationController(rootViewController: mainViewController)
        //navigationController.style(hidden: false)
        window!.rootViewController = navigationController
        window!.makeKeyAndVisible()
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    @available(iOS 10, *)
    private func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let aps = userInfo["aps"] as! [String: AnyObject]
        
        if let newsItem = NewsItem.makeNewsItem(aps){
            if response.actionIdentifier == viewActionIdentifier,
                let url = URL(string: newsItem.link){
                let safari = SFSafariViewController(url: url)
                window?.rootViewController?.present(safari, animated: true, completion: nil)
            }
        }
        completionHandler([.alert, .sound, .badge])
    }
        
   
}

