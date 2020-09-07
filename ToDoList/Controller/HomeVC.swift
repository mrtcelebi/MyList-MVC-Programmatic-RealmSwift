//
//  ViewController.swift
//  ToDoList
//
//  Created by Catalina on 9.08.2020.
//  Copyright © 2020 Catalina. All rights reserved.
//

import UIKit
import SwipeCellKit
import RealmSwift

final class HomeVC: UIViewController {

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(SwipeTableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    let realm = try! Realm()
    
    var items : Results<Item>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        title = "MyList"
        navigationController?.navigationBar.prefersLargeTitles = true
        configureTableView()
        addRightBarButton()
        loadItems()
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.bounds
    }
    
    func addRightBarButton(){
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToList))
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc private func addToList() {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add",
                                      message: "Type below to add new item.",
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Save", style: .default) {[weak self] alert in
            
            guard let self = self else { return }
            let newItem = Item()
            guard let textField = textField.text, !textField.isEmpty else { return }
            newItem.name = textField
            self.saveItems(item: newItem)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "New item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func saveItems(item: Item) {
        do {
            try realm.write() {
                realm.add(item)
            }
        }
        catch {
            self.simpleAlert(title: "Error", message: "Error saving item.")
        }
    }
    
    private func loadItems() {
        items = realm.objects(Item.self)
    }
    
    private func deleteItems(indexPath: IndexPath) {
        if let selectedItem = self.items?[indexPath.row] {
            do {
                try realm.write() {
                    realm.delete(selectedItem)
                }
            }
            catch {
                self.simpleAlert(title: "Error", message: "Error deleting item.")
            }
        }
    }
    
    private func simpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - TableView DataSource and SwipeTableViewCellDelegate Methods

extension HomeVC: UITableViewDataSource , SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        cell.textLabel?.text = items?[indexPath.row].name ?? ""
        
        if let item = items?[indexPath.row] {
            cell.accessoryType = item.done ? .checkmark : .none
        }        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [weak self] action, indexPath in
       
            guard let self = self else { return }
            self.deleteItems(indexPath: indexPath)
                
        }
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}


// MARK: - TableView Delegate Methods

extension HomeVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let item = items?[indexPath.row] else { return }
        
        do {
            try realm.write {
                item.done = !item.done
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } catch {
            self.simpleAlert(title: "Error", message: "Could not save done action.")
        }
    }
}
