//
//  LocalNotificationManager.swift
//  To Do List
//
//  Created by Brishti Saha on 3/7/21.
//

import UIKit
import UserNotifications

struct LocalNotificationManager {
    
    static func authorizeLocalNotification(viewController: UIViewController) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            guard error == nil else{
                print("😡 Error \(error!.localizedDescription)")
                return
            }
            if granted {
                print("✅ Notifications Authorization Granted")
            } else{
                print("🚫 The user has denied notifications")
                DispatchQueue.main.async {
                    viewController.oneButtonAlert(title: "User Disabled Notifications", message: "To receive alerts open the settings app, select To Do List, and turn on notifications")
                }
            }
        }
    }
    
    static func isAuthorized(completed: @escaping (Bool)->() ) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            guard error == nil else{
                print("😡 Error \(error!.localizedDescription)")
                completed(false)
                return
            }
            if granted {
                print("✅ Notifications Authorization Granted")
                completed(true)
            } else{
                print("🚫 The user has denied notifications")
                completed(false)
                
            }
        }
    }
    
    static func setCalenderNotification(title: String, subtitle: String, body: String, badgeNumber: NSNumber?, sound: UNNotificationSound?, date: Date)->String {
        //create content
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = sound
        content.badge = badgeNumber
        
        //create trigger
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        dateComponents.second = 00
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        //create request
        let notificationID = UUID().uuidString
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error{
                print("😡 Error: \(error.localizedDescription) Yikes, adding notification requests went wrong!")
            } else{
                print("Notification scheduled \(notificationID), title: \(content.title)")
            }
        }
        return notificationID
    }
}
