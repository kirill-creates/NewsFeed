//
//  CategoryItemCell.swift
//  NewsFeed
//
//  Created by Kirill on 27.06.2025.
//

import UIKit


final class CategoryItemCell: BaseItemCell {
    
    private let dateLabel = UILabel()
    
    override func setupUI() {
        contentView.layer.cornerRadius = 12
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true

        // MARK: - Image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        // MARK: - Gradient
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(gradientView)

        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: imageView.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            gradientView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor)
        ])

        gradientView.gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor
        ]
        gradientView.gradientLayer.locations = [0, 1]

        // MARK: - Title
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 4
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8)
        ])

        // MARK: - Date
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .white
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            //dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8)
        ])
    }
    
    override func configure(with item: NewsItem) {
        titleLabel.text = item.title
        dateLabel.text = formattedDate(from: item.publishedDate)
    }
    
    private func formattedDate(from string: String) -> String {
        guard let date = DateFormatter.newsParsingFormatter.date(from: string) else { return "" }
        return DateFormatter.newsDisplayFormatter.string(from: date)
    }
}
