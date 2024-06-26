//
//  MenuSectionTableViewCell.swift
//  Dine
//
//  Created by doss-zstch1212 on 07/05/24.
//

import UIKit

class MenuSectionTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "MenuSectionTableViewCell"
    
    private lazy var customSFSymbol: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .black
        return imageView
    }()
    
    private lazy var sectionTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var customDisclosureImage: UIImageView = {
        let imageView = UIImageView()
        let sfConfiguration = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 14, weight: .bold), scale: .large)
        imageView.image = UIImage(systemName: "chevron.forward", withConfiguration: sfConfiguration)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupSubviews() {
        contentView.addSubview(sectionTitle)
        contentView.addSubview(customSFSymbol)
//        contentView.addSubview(customDisclosureImage)
        contentView.backgroundColor = /*UIColor(named: "primaryBgColor")*/.systemBackground
        
        
        NSLayoutConstraint.activate([
            customSFSymbol.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            customSFSymbol.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            customSFSymbol.heightAnchor.constraint(equalToConstant: 55),
            customSFSymbol.widthAnchor.constraint(equalToConstant: 55),
            sectionTitle.leadingAnchor.constraint(equalTo: customSFSymbol.trailingAnchor, constant: 8),
            sectionTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 11),
            sectionTitle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -11),
            sectionTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            /*customDisclosureImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 11),
            customDisclosureImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            customDisclosureImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -11),
            customDisclosureImage.leadingAnchor.constraint(equalTo: sectionTitle.trailingAnchor, constant: 8)*/
            
        ])
        
    }
    
    func configure(title: String) {
        sectionTitle.text = title
    }

}
