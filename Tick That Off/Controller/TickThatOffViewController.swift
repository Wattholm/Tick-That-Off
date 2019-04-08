//
//  ViewController.swift
//  Tick That Off
//
//  Created by Kevin Joseph Mangulabnan on 04/11/2018.
//  Copyright © 2018 Kevin Joseph Mangulabnan. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import ChameleonFramework

class TickThatOffViewController: UITableViewController  {

    @IBOutlet weak var searchBar: UISearchBar!

    let realm = try! Realm()

    var notificationToken: NotificationToken? = nil

    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }

    var itemResults: Results<Item>?
    
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    //Alternate Solution for using NSUserDefaults as the 'Database' - see the relevant commit
    //var itemArray: [String] = ["Find Mike","Buy Eggos","Destroy Demogorgon"]
    //var checkedArray: [Bool] = [false,true,false]
    
    //let itemArrayKey = "defaultItems"
    //let checkedArrayKey = "defaultChecked"
    
    //let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        
        // Observe Results Notifications
        notificationToken = itemResults?.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
        
        
        //Used to print out the location in the device's filesystem where our data will be saved
        
        //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //print(dataFilePath)
        
        //Clear UserDefaults Array Values as Needed
        //defaults.removeObject(forKey: defaultsItemArrayKey)
        //Problem with Course code is that you cannot now insert objects [Item] into the userdefaults property list

        //Alternate code: see 5th commit
//        if let items = defaults.array(forKey: itemArrayKey) as? [String] {
//            itemArray = items
//        }
//
//        if let booleans = defaults.array(forKey: checkedArrayKey) as? [Bool] {
//            checkedArray = booleans
//        }
        
        //loadItems is now triggered in the didset{} method of selectedCategory
        //loadItems()
        
        //tableView.reloadData()
        
        //let newItem = Item()
        //newItem.title = "Find Mike Again"
        //itemArray.append(newItem)
    }
    
    override func viewWillAppear(_ animated: Bool) {

        //The code navigationController?.navigationBar will not work because it does not exist at this point
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not yet exist.")}

        guard let hexColor = selectedCategory?.bgColor else {fatalError()}
        
        title = selectedCategory?.name
        
        navBar.barTintColor = UIColor(hexString: hexColor)
        
        navBar.tintColor = ContrastColorOf(UIColor(hexString: hexColor)!, returnFlat: true)
        
        // Will apply to versions before iOS 11
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: navBar.tintColor]
        
        if #available(iOS 11.0, *) {
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: navBar.tintColor]
        }
        
        searchBar.barTintColor = UIColor(hexString: hexColor)
        
        //tableView.reloadData()
    }

    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemResults?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let item = itemResults?[indexPath.row] {
        
            cell.textLabel?.text = item.title
            
            if let newColor = UIColor(hexString: selectedCategory!.bgColor)?.darken(byPercentage:
                CGFloat(indexPath.row) / CGFloat(itemResults!.count) / CGFloat(2)
                ) {
                
                cell.backgroundColor = newColor
                cell.textLabel?.textColor = ContrastColorOf(newColor, returnFlat: true)
            }
            
            cell.accessoryType = item.checked ? .checkmark : .none
        
        } else {
            cell.textLabel?.text = "[NO ITEMS]"
        }
        
        return cell
    }
    
    // Tableview Method to implement Swipe Deletion
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        deleteCell(at: indexPath)
        //tableView.reloadData()
    }
    
    
    //MARK - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //  Code to alternatively delete the item at specified row
        //  context.delete(itemArray[indexPath.row])
        //  itemArray.remove(at: indexPath.row)
       
        if let item = itemResults?[indexPath.row] {
            do {
                try realm.write {
                    item.checked = !item.checked
                }
            } catch {
                print("Error saving checked status, \(error)")
            }
            
        }
        
        //tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New List Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
           
            //what will happen once Add Item is clicked inside the UIAlert

            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving item: \(error)")
                }
            }
            
            //self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert,animated: true,completion: nil)
        
    }
    
    //MARK - Model Manipulation Methods
    
//    func saveItems() {
//
//        do {
//            //try context.save()
//        } catch {
//            print("Error saving context: \(error)")
//        }
//
//        tableView.reloadData()
//
//    }
    
    //default value of request is "Item.fetchrequest()" if no argument is passed in
    
    func loadItems() {
        itemResults = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        //tableView.reloadData()
    }

    //MARK: - Delete Data from Swipe
    func deleteCell(at indexPath: IndexPath) {
        if let itemToDelete = itemResults?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(itemToDelete)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
            
            //Not sure why this is not part of the code after editActionsOptionsForRowAt was added
            //tableView.reloadData()
        }
    }
    
}




extension TickThatOffViewController: UISearchBarDelegate {

    //Delegate Method is required for VC to be the delegate of UISearchBar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        loadItems()
        
        //Slight modification to allow sorting by dateCreated with an empty search string
        //Shows all results by Date instead of none
        
        if searchBar.text! == "" {
            itemResults = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        } else {
            itemResults = selectedCategory?.items.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        }
        
        tableView.reloadData()
        
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        //Remove the keyboard and cursor and show ALL the DATA when UISearchBar X button is pressed to clear the query text
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }


        }
    }

}
