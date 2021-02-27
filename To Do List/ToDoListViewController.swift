//
//  ViewController.swift
//  To Do List
//
//  Created by Brishti Saha on 2/27/21.
//

import UIKit

class ToDoListViewController: UIViewController {


    @IBOutlet weak var tableView: UITableView!
    
    var toDoArray = ["Learn Swift", "Build an app", "Study for exam"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }


}

extension ToDoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numbersOfRowsInSection \(toDoArray.count)")
        return toDoArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt \(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = toDoArray[indexPath.row]
        return cell
    }
    
}
