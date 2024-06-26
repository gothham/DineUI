//
//  AddSectionViewController.swift
//  Dine
//
//  Created by doss-zstch1212 on 27/06/24.
//

import UIKit

class AddSectionViewController: UIViewController {
    
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add Section"
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var categoryNameTextField: UITextField = {
        let textField = DTextField()
        textField.placeholder = "Category Name"
        textField.backgroundColor = .secondarySystemGroupedBackground
        textField.layer.cornerRadius = 10
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Section", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .app
        button.addTarget(self, action: #selector(addButtonAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Add Section"
        navigationController?.navigationBar.prefersLargeTitles = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        // tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        setupSubviews()
    }
    
    @objc private func addButtonAction(_ sender: UIButton) {
        print(#function)
        guard let categoryName = categoryNameTextField.text,
              !categoryName.isEmpty else { return }
        do {
            let categoryService = try CategoryServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            let category = MenuCategory(id: UUID(), categoryName: categoryName)
            try categoryService.add(category)
            // Post Notification
            NotificationCenter.default.post(name: .categoryDataDidChangeNotification, object: nil)
            self.dismiss(animated: true)
        } catch {
            print("Failed to load categories: \(error)")
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupSubviews() {
        view.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(categoryNameTextField)
        verticalStackView.addArrangedSubview(addButton)
        

        NSLayoutConstraint.activate([
            verticalStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            verticalStackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8),
            verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            categoryNameTextField.heightAnchor.constraint(equalToConstant: 44),
            addButton.heightAnchor.constraint(equalToConstant: 55),
        ])
    }
    
}
