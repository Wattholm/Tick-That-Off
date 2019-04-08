//
//  CategoryViewController.swift
//  Tick That Off
//
//  Created by Kevin Joseph Mangulabnan on 21/11/2018.
//  Copyright © 2018 Kevin Joseph Mangulabnan. All rights reserved.
//

import UIKit
//import Foundation
import RealmSwift
import ChameleonFramework

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var notificationToken: NotificationToken? = nil
    
    var categoryResults: Results<Category>?
    
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        
        tableView.rowHeight = 80
        loadCategories()
        tableView.separatorStyle = .none
        
        // Observe Results Notifications
        notificationToken = categoryResults?.observe { [weak self] (changes: RealmCollectionChange) in
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
        
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //The code navigationController?.navigationBar will not work because it does not exist at this point
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not yet exist.")}
        
        //CGRect for the gradient colors of the Navigation Bar (must get dimensions of navBar + statusBar and add them)
        let rect = CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: navBar.bounds.width, height: navBar.bounds.height + UIApplication.shared.statusBarFrame.height)
        )
        
        let hexColor = GradientColor(UIGradientStyle.topToBottom,
                                     frame: rect,
                                     colors: [FlatRed(),FlatYellow()])
        
        navBar.barTintColor = hexColor
        
        navBar.tintColor = ContrastColorOf(hexColor, returnFlat: true)
        
        // Will apply to versions before iOS 11
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: navBar.tintColor]
        
        if #available(iOS 11.0, *) {
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: navBar.tintColor]
        }
        
        //tableView.reloadData()
        
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoryResults?.count ?? 1
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        
        //let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categoryResults?[indexPath.row] {
            cell.textLabel?.text = category.name
            //cell.backgroundColor = UIColor.randomFlat
            guard let newColor = UIColor(hexString: category.bgColor) else {fatalError()}
            cell.backgroundColor = newColor
            cell.textLabel?.textColor = ContrastColorOf(newColor, returnFlat: true)
        } else {
            cell.textLabel?.text = "[NO CATEGORIES]"
        }
        
        cell.selectionStyle = .none
        
        return cell

    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        deleteCell(at: indexPath)
        //tableView.reloadData()
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //perform segue, passing on the category name
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! TickThatOffViewController
        
        //must create a variable in the destinationVC; an optional of type Category that gets set once the segue completes
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryResults?[indexPath.row]
        }
        
    }

    
    
    //MARK: - Data Manipulation Methods
    
    func loadCategories() {
        
        categoryResults = realm.objects(Category.self)
        
//        let request: NSFetchRequest<Category> = Category.fetchRequest()
//
//        do {
//            categoryResults = try context.fetch(request)
//        } catch {
//            print("Error fetching Category Data from Context: \(error)")
//        }
//
//        tableView.reloadData()
        
    }
    
    
    func save(category: Category) {

        do {
            try realm.write{
                realm.add(category)
            }
        } catch {
            print("Error saving categories to database: \(error)")
        }
        
        //tableView.reloadData()
    }
    
    //MARK: - Delete Data from Swipe
    
    func deleteCell(at indexPath: IndexPath) {
        if let categoryToDelete = categoryResults?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(categoryToDelete)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
            
            //Not sure why this is not part of the code after editActionsOptionsForRowAt was added
            //tableView.reloadData()
        }
    }
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            
            newCategory.bgColor = UIColor.init(randomFlatColorOf: .light).hexValue()
            
            //self.categoryResults.append(newCategory)
            self.save(category: newCategory)
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
}
