//
//  ViewController.swift
//  Tick That Off
//
//  Created by Kevin Joseph Mangulabnan on 04/11/2018.
//  Copyright © 2018 Kevin Joseph Mangulabnan. All rights reserved.
//

import UIKit
import Foundation

class TickThatOffViewController: UITableViewController {

    var itemArray: [String] = ["Find Mike","Buy Eggos","Destroy Demogorgon"]
    var checkedArray: [Bool] = [false,true,false]
    
    let itemArrayKey = "defaultItems"
    let checkedArrayKey = "defaultChecked"
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Clear UserDefaults Array Values as Needed
        //defaults.removeObject(forKey: defaultsItemArrayKey)
        //Problem with Course code is that you cannot now insert objects [Item] into the userdefaults property list
        
        if let items = defaults.array(forKey: itemArrayKey) as? [String] {
            itemArray = items
        }
        
        if let booleans = defaults.array(forKey: checkedArrayKey) as? [Bool] {
            checkedArray = booleans
        }
        
        tableView.reloadData()
        
        //let newItem = Item()
        //newItem.title = "Find Mike Again"
        //itemArray.append(newItem)
        
    }

    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let title = itemArray[indexPath.row]
        let checked = checkedArray[indexPath.row]
        
        cell.textLabel?.text = title
 
        //ternary operator usage instead of the commented out code below
        cell.accessoryType = checked ? .checkmark : .none
        
//        if checked {
//            cell.accessoryType = .checkmark
//        } else {
//            cell.accessoryType = .none
//        }
//
        self.defaults.set(self.itemArray, forKey: self.itemArrayKey)
        self.defaults.set(self.checkedArray, forKey: self.checkedArrayKey)
        
        return cell
    }
    
    //MARK - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Toggle checkmark accessory by toggling the Item.checked property
        
        checkedArray[indexPath.row] = !checkedArray[indexPath.row]

       
//        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
//           tableView.cellForRow(at: indexPath)?.accessoryType = .none
//        } else {
//           tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.reloadData()
        
    }
    
    //MARK - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New List Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
           
            //what will happen once Add Item is clicked inside the UIAlert
            self.itemArray.append(textField.text!)
            self.checkedArray.append(false)
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert,animated: true,completion: nil)
        
    }
    
}

