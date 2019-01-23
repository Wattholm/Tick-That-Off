//
//  CategoryViewController.swift
//  Tick That Off
//
//  Created by Kevin Joseph Mangulabnan on 21/11/2018.
//  Copyright © 2018 Kevin Joseph Mangulabnan. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categoryResults: Results<Category>?
    
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }

    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoryResults?.count ?? 1
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categoryResults?[indexPath.row].name ?? "[NO CATEGORIES]"
        
        //cell.textLabel?.text = item.name
        
        return cell
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
        
        tableView.reloadData()
    }
    
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
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
