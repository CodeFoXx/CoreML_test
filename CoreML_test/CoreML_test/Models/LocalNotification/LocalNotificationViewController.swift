//
//  LocalNotificationViewController.swift
//  CoreML_test
//
//  Created Осина П.М. on 12.03.18.
//  Copyright © 2018 Осина П.М.. All rights reserved.
//

import UIKit
import UserNotifications

class LocalNotificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UNUserNotificationCenterDelegate {
    

    @IBOutlet weak var txtAddItem: UITextField!
    
    @IBOutlet weak var tblShoppingList: UITableView!
    
    @IBOutlet weak var btnAction: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
	var presenter: LocalNotificationPresenter!
    
    var shoppingList: NSMutableArray!

	override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblShoppingList.delegate = self
        self.tblShoppingList.dataSource = self
        
        self.txtAddItem.delegate = self
        
        datePicker.isHidden = true
        
        configureNotificationsCenter()
        
        loadShoppingList()
    }
    
    @IBAction func sheduleReminder(_ sender: Any) {
        if datePicker.isHidden {
            animateMyView(viewToHide: tblShoppingList, viewToShow: datePicker)
        }
        else{
            animateMyView(viewToHide: datePicker, viewToShow: tblShoppingList)
//            scheduleLocalNotification(identifier: "identifier", title: "title", subtitle: "subtitle", body: "body", timeInterval: TimeInterval(datePicker.date.timeIntervalSinceNow))

            UNUserNotificationCenter.current().getNotificationSettings{ (notificationSettings) in
                switch notificationSettings.authorizationStatus {
                case .notDetermined:
                    self.requestAuthorization(completionHandler: { (success) in
                        guard success else {return}
                        
                        self.schedualeLocalLotification()
                        })
                case.authorized:
                    self.schedualeLocalLotification()
                case.denied:
                    print("Application not allowed to Display Notification")
                }
            }
            
        }
        txtAddItem.isEnabled = !txtAddItem.isEnabled
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if shoppingList == nil {
            shoppingList = NSMutableArray()
        }
        shoppingList.add(textField.text)
        
        tblShoppingList.reloadData()
        
        txtAddItem.text = ""
        txtAddItem.resignFirstResponder()
        
        saveShoppingList()
        
        configureNotificationsCenter()
        
        return true
    }
    
    func removeItemAtIndex(index: Int){
        shoppingList.removeObject(at: index)
        saveShoppingList()
        tblShoppingList.reloadData()
    }
    
    func saveShoppingList(){
        let pathsArray = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory = pathsArray[0] as String
        let savePath = documentsDirectory.appending("shopping_list")
        shoppingList.write(toFile: savePath, atomically: true)
    }
    
    func loadShoppingList(){
        let pathsArray = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectory = pathsArray[0] as String
        let shoppingListPath = documentDirectory.appending("shopping_list")
        
        if FileManager.default.fileExists(atPath: shoppingListPath){
            shoppingList = NSMutableArray(contentsOfFile: shoppingListPath)
            tblShoppingList.reloadData()
        }
    }
    
    func animateMyView(viewToHide: UIView, viewToShow: UIView){
        let animationDuration = 0.35
        
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            viewToHide.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        }) { (completion) -> Void in
            viewToHide.isHidden = true
            viewToShow.isHidden = false
            
            viewToShow.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            
            UIView.animate(withDuration: animationDuration, animations: { () -> Void in
                viewToShow.transform = .identity
            })
        }
        
    }
    

    
    func scheduleLocalNotification(identifier: String, title: String, subtitle: String, body: String, timeInterval: TimeInterval, repeats: Bool = false){
        
        if #available(iOS 10, *){
            let content = UNMutableNotificationContent()
            content.title = title
            content.subtitle = subtitle
            content.body = body
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: repeats)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }else{
            let notification = UILocalNotification()
            notification.alertBody = "\(title)\n\(subtitle)\n\(body)"
            notification.fireDate = Date(timeIntervalSinceNow: 1)
            
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
    
    private func schedualeLocalLotification(){
        
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = "Test"
        notificationContent.subtitle = "Local Notification"
        notificationContent.body = "Bla-Bla-Bla-Bla-Bla-Bla-Bla-Bla-Bla-Bla-Bla-Bla-Bla-Bla-Bla-Bla-Bla-Bla-Bla-Bla-Bla-Bla-Bla-Bla-Bla-Bla-"
        
        notificationContent.categoryIdentifier = NotificationSettings.Category.tutorial
        
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 2.0, repeats: false)
        
        let notificationRequest = UNNotificationRequest(identifier: String(datePicker.date.timeIntervalSinceNow), content: notificationContent, trigger: notificationTrigger)
        
        UNUserNotificationCenter.current().add(notificationRequest) {
            (error) in
            if let error = error {
                print("Unable to add notification")
            }
        }
        
    }
    
    private func configureNotificationsCenter(){
        UNUserNotificationCenter.current().delegate = self
        
        let actionReadLater = UNNotificationAction(identifier: NotificationSettings.Action.later, title: "Read Later", options: [.destructive])
        let actionShowDetails = UNNotificationAction(identifier: NotificationSettings.Action.showDetails, title: "Show Details", options: [.foreground])
        let actionUnsubscribe = UNNotificationAction(identifier: NotificationSettings.Action.unsubscribe, title: "Unsubscribe", options: [.foreground])
        
        let tutorialCategory = UNNotificationCategory(identifier: NotificationSettings.Category.tutorial, actions: [actionReadLater, actionShowDetails, actionUnsubscribe], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([tutorialCategory])
    }
    
    private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            completionHandler(success)
        }
    }
    
}

extension LocalNotificationViewController: LocalNotificationView {
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //15 -
        completionHandler([.alert, .sound])
    }
    
    //16 -
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        //17 -
        if response.actionIdentifier == "y = mx + b" {
            txtAddItem.text = "That's the correct answer!"
        } else if response.actionIdentifier == "Ax + By = C" {
            txtAddItem.text = "Sorry, that's the standard form equation."
        } else {
            txtAddItem.text = "Keep trying!"
        }
    }
    
    func registerForNotifications(types: UIUserNotificationType){
        if #available(iOS 10.0, *){
            let options = types.authorizationOptions()
            UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }else{
            let settings = UIUserNotificationSettings(types: types, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        if let list = shoppingList{
            rows = list.count
        }
        
        return rows
    }
    
    func tableView(_ tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "localNotifyCellItem") as! UITableViewCell
        cell.textLabel?.text = shoppingList.object(at: indexPath.row) as! NSString as String
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            removeItemAtIndex(index: indexPath.row)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}
