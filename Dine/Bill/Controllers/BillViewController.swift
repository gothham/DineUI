//
//  BillViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 07/05/24.
//

import UIKit
import SwiftUI

class BillViewController: UIViewController, UITableViewDataSource {
    // MARK: - Properties
    private var tableView: UITableView!
    private var cellReuseIdentifier = "BillItem"
//    private var billData: [BillData] = ModelData().bills
    private var billData: [Bill] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var filterBarButton: UIBarButtonItem!
    
    // MARK: -View LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        view = tableView
        setupAppearance()
        setupBarButton()
        loadBillData()
        NotificationCenter.default.addObserver(self, selector: #selector(billDidAdd(_:)), name: .billDidAddNotification, object: nil)
    }
    
    @objc private func billDidAdd(_ sender: NotificationCenter) {
        loadBillData()
    }
    
    // MARK: - Methods
    private func setupTableView() {
        tableView = UITableView(frame: .zero)
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.dataSource = self
    }
    
    private func setupAppearance() {
        self.title = "Bills"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupBarButton() {
        filterBarButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .plain, target: self, action: #selector(filterAction(_:)))
        navigationItem.rightBarButtonItem = filterBarButton
    }
    
    @objc private func filterAction(_ sender: UIBarButtonItem) {
        print("Filter button tapped!")
        
    }
    
    private func loadBillData() {
        do {
            let databaseAccess = try SQLiteDataAccess.openDatabase()
            let billService = BillServiceImpl(databaseAccess: databaseAccess)
            let results = try billService.fetch()
            if let results {
                billData = results
            }
        } catch {
            print("Unable to load bills = \(error)")
        }
    }
    
    // MARK: - TableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        billData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        let item = billData[indexPath.row]
        cell.selectionStyle = .none
        cell.contentConfiguration = UIHostingConfiguration {
            BillItem(billData: item)
        }
        return cell
    }
}

#Preview  {
    let billVC = BillViewController()
    billVC.title = "Bills"
    return UINavigationController(rootViewController: BillViewController())
}

