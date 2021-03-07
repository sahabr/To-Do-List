//
//  ViewController.swift
//  To Do List
//
//  Created by Brishti Saha on 2/27/21.
//

import UIKit
import UserNotifications

class ToDoListViewController: UIViewController {


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    //var toDoItems: [ToDoItem] = []
    var toDoItems = ToDoItems()
    //var toDoArray = ["Learn Swift", "Build an app", "Study for exam"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        toDoItems.loadData {
            self.tableView.reloadData()
        }
        authorizeLocalNotification()
    }
    
    func authorizeLocalNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            guard error == nil else{
                print("😡 Error \(error!.localizedDescription)")
                return
            }
            if granted {
                print("✅ Notifications Authorization Granted")
            } else{
                print("🚫 The user has denied noifcations")
                //TODO: Put an alert in here telling the user what to do
            }
        }
    }
    
    func setNotifications() {
        guard toDoItems.itemsArray.count>0 else{
            return
        }
        //remove all notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        //and let's re-create them with the updated data that we just saved
        for index in 0..<toDoItems.itemsArray.count{
            if toDoItems.itemsArray[index].reminderSet {
                let toDoItem = toDoItems.itemsArray[index]
                toDoItems.itemsArray[index].notificationID = setCalenderNotification(title: toDoItem.name, subtitle: "", body: toDoItem.notes, badgeNumber: nil, sound: .default, date: toDoItem.date)
            }
        }
    }
    
    func setCalenderNotification(title: String, subtitle: String, body: String, badgeNumber: NSNumber?, sound: UNNotificationSound?, date: Date)->String {
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
    

    
    func saveData() {
        toDoItems.saveData()
        setNotifications()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let destination = segue.destination as! ToDoDetailTableViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.toDoItem = toDoItems.itemsArray[selectedIndexPath.row]
        }
    }
    
    @IBAction func unwindFromDetail(segue: UIStoryboardSegue) {
        let source = segue.source as! ToDoDetailTableViewController
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            toDoItems.itemsArray[selectedIndexPath.row] = source.toDoItem
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)

        } else {
            let newIndexPath = IndexPath(row: toDoItems.itemsArray.count, section: 0)
            toDoItems.itemsArray.append(source.toDoItem)
            tableView.insertRows(at: [newIndexPath], with: .bottom)
            tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
        }
        saveData()
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            sender.title = "Edit"
            addBarButton.isEnabled = true
        }else {
            tableView.setEditing(true, animated: true)
            sender.title = "Done"
            addBarButton.isEnabled = false
        }
    }
    
}

extension ToDoListViewController: UITableViewDelegate, UITableViewDataSource, ListTableViewCellDelegate {
    
    func checkBoxToggle(sender: ListTableViewCell) {
        if let selectedIndexPath = tableView.indexPath(for: sender){
            toDoItems.itemsArray[selectedIndexPath.row].completed = !toDoItems.itemsArray[selectedIndexPath.row].completed
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
            saveData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems.itemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ListTableViewCell
        cell.delegate = self
        cell.nameLabel.text = toDoItems.itemsArray[indexPath.row].name
        cell.checkBoxButton.isSelected = toDoItems.itemsArray[indexPath.row].completed
        cell.toDoItem = toDoItems.itemsArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            toDoItems.itemsArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveData()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = toDoItems.itemsArray[sourceIndexPath.row]
        toDoItems.itemsArray.remove(at: sourceIndexPath.row)
        toDoItems.itemsArray.insert(itemToMove, at: destinationIndexPath.row)
        saveData()
    }
    
    
}
