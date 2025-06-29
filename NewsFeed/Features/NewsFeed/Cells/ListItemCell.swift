//
//  ListItemCell.swift
//  NewsFeed
//
//  Created by Kirill on 27.06.2025.
//

import UIKit


final class ListItemCell: BaseItemCell {
    
    private let dateLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .tertiaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func setupUI() {
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        contentView.backgroundColor = .secondarySystemBackground
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.numberOfLines = 2
        
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .secondaryLabel
        
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .label
        descriptionLabel.numberOfLines = 2
        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.minimumScaleFactor = 0.6
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, dateLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        let mainStack = UIStackView(arrangedSubviews: [imageView, textStack, arrowImageView])
        mainStack.axis = .horizontal
        mainStack.spacing = 8
        mainStack.alignment = .top
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
            imageView.heightAnchor.constraint(equalToConstant: 160),
            
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    override func configure(with item: NewsItem) {
        titleLabel.text = item.title
        descriptionLabel.text = item.description.trimmingCharacters(in: .whitespacesAndNewlines)
        dateLabel.text = formattedDate(from: item.publishedDate)
    }
    
    private func formattedDate(from string: String) -> String {
        guard let date = DateFormatter.newsParsingFormatter.date(from: string) else { return "" }
        return DateFormatter.newsDisplayFormatter.string(from: date)
    }
}


