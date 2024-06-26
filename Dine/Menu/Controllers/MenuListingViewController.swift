//
//  MenuListingViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 23/05/24.
//

import UIKit
import SwiftUI
import Toast

class MenuListingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var tableView: UITableView!
    private var placeholderLabel: UILabel!
    private let cellReuseID = "MenuItemRow"
    private let activeSection: MenuSectionType
    private let category: MenuCategory
    
    private var menuData: [MenuItem] = [] {
        didSet {
            updateUIForMenuItemData()
        }
    }
    
    // Search essentials
    private var filteredItems: [MenuItem] = []
    private var searchController: UISearchController!
    var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }
    
    var isSearchBarEmpty: Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }
    
    init(activeSection: MenuSectionType, category: MenuCategory) {
        self.activeSection = activeSection
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupPlaceholderLabel()
        title = category.categoryName
        navigationController?.navigationBar.prefersLargeTitles = true
        setupSearchBar()
        setupNavbar()
        populateMenuData()
        NotificationCenter.default.addObserver(self, selector: #selector(menuItemDidChange(_:)), name: .menuItemDidChangeNotification, object: nil)
    }
    
    @objc private func menuItemDidChange(_ sender: NotificationCenter) {
        populateMenuData()
        tableView.reloadData()
    }
    
    @objc private func addMenuItemButtonTapped(_ sender: UIBarButtonItem) {
        print("Add menu button tapped")
        let addMenuVC = AddItemViewController(category: category)
        if let sheet = addMenuVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
        }
        
        present(addMenuVC, animated: true)
    }
    
    private func setupPlaceholderLabel() {
        placeholderLabel = UILabel()
        placeholderLabel.text = "Add Menu Items to Continue"
        placeholderLabel.textColor = .systemGray3
        placeholderLabel.font = .preferredFont(forTextStyle: .title1)
        placeholderLabel.textAlignment = .center
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Initially hidden
        placeholderLabel.isHidden = true
    }
    
    // Load methods
    private func populateMenuData() {
        do {
            let dataAccess = try SQLiteDataAccess.openDatabase()
            let menuService = MenuServiceImpl(databaseAccess: dataAccess)
            let results = try menuService.fetch()
            if let results = results {
                let menuItemForSection = results.filter { $0.category.id == category.id }
                DispatchQueue.main.async {
                    self.menuData = menuItemForSection
                    self.tableView.reloadData()
                }
            }
        } catch {
            print("Unable to fetch menu items - \(error)")
        }
    }
    
    private func updateUIForMenuItemData() {
        let hasMenuItems = !menuData.isEmpty
        tableView.isHidden = !hasMenuItems
        placeholderLabel.isHidden = hasMenuItems
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func setupNavbar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMenuItemButtonTapped(_:)))
        navigationItem.rightBarButtonItem = addButton
    }
    
    
    private func setupSearchBar() {
        searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Items"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func filterContentForSearch(_ searchText: String)  {
        filteredItems = menuData.filter { (menuData: MenuItem) -> Bool in
            menuData.name.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Destructive actions
    private func deleteMenuItem(_ menuItem: MenuItem) {
        do {
            let menuService = try MenuServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            let menuController = MenuController(menuService: menuService)
            try menuController.removeItemFromMenu(menuItem)
        } catch {
            print("Failed to perform \(#function) - \(error)")
        }
    }
    
    func presentWarning(for item: MenuItem) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Delete", message: "Do you want to delete the order?", preferredStyle: .alert)
        
        // Create the 'Delete' action
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }
            // Handle the delete action
            print("Order deleted")
            self.deleteMenuItem(item) // delete
            populateMenuData() // fetch
            tableView.reloadData() // reload to reflect
        }
        
        // Create the 'Add Items' action
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
            // Handle the add items action
            // guard let self else { return }
            print("Cancelled")
        }
        
        // Add the actions to the alert controller
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isFiltering ? filteredItems.count : menuData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath)
        cell.selectionStyle = .none
        let menuItem = isFiltering ? filteredItems[indexPath.row] : menuData[indexPath.row]
        cell.contentConfiguration = UIHostingConfiguration {
            MenuItemRow(menuItem: menuItem)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuItem = isFiltering ? filteredItems[indexPath.row] : menuData[indexPath.row]
        let menuDetailViewHostVC = UIHostingController(rootView: MenuDetailView(menuItem: menuItem))
        navigationController?.pushViewController(menuDetailViewHostVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = menuData[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completionHandler in
            guard let self else { return }
            print("Delete action")
            presentWarning(for: item)
            
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let item = menuData[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { [weak self] action in
                // Handle action 1
                guard let self else { return }
                print("Edit context menu action")
                self.presentEditAlertController(for: item)
                
            }
            /*let action2 = UIAction(title: "Action 2", image: UIImage(systemName: "heart")) { action in
                // Handle action 2
                print("Action 2 tapped")
            }*/
            return UIMenu(title: "", children: [editAction])
        }
    }
    
    private func presentEditAlertController(for item: MenuItem) {
        let alertController = UIAlertController(title: "Edit Item", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Name"
            textField.text = item.name
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Price"
            textField.keyboardType = .decimalPad
            textField.text = String(item.price)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.dismiss(animated: true)
        }
        
        let doneAction = UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            guard let self else { return }
            guard let firstTextField = alertController.textFields?[0],
                  let secondTextField = alertController.textFields?[1] else { return }
            
            guard let name = firstTextField.text,
                  !name.isEmpty else {
                self.showToast("Invalid Name")
                return
            }
            
            guard let priceText = secondTextField.text,
                  !priceText.isEmpty,
                  let price = Double(priceText) else {
                self.showToast("Invalid price")
                return
            }
            
            
            // Handle the text input
            print("Name text field: \(name)")
            print("Price text field: \(price)")
            
            let updatedItem = MenuItem(itemId: item.itemId, name: name, price: price, category: item.category)
            editItem(updatedItem)
            let toast = Toast.text("Updated!")
            toast.show(haptic: .success)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(doneAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func editItem(_ item: MenuItem) {
        do {
            let menuService = try MenuServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            try menuService.update(item)
            if let index = menuData.firstIndex(where: { $0 == item }) {
                menuData[index].name = item.name
                menuData[index].price = item.price
                tableView.reloadData()
            }
        } catch {
            fatalError("Updating menu item failed!") // Will be removed in production!
        }
    }
    
    private func showToast(_ message: String) {
        let toast = Toast.text(message)
        toast.show(haptic: .error)
    }
}

extension MenuListingViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearch(searchBar.text!)
    }
}

#Preview{
    UINavigationController(
        rootViewController: MenuListingViewController(
            activeSection: .mainCourse,
            category: MenuCategory(
                id: UUID(),
                categoryName: "Starter"
            )
        )
    )
}
