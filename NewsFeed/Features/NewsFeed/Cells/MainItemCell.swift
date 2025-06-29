//
//  MainItemCell.swift
//  NewsFeed
//
//  Created by Kirill on 27.06.2025.
//

import UIKit


final class MainItemCell: BaseItemCell {
    
    private let leftArrow = UIImageView(image: UIImage(systemName: "chevron.left"))
    private let rightArrow = UIImageView(image: UIImage(systemName: "chevron.right"))
    
    override func setupUI() {
        contentView.clipsToBounds = true
        contentView.layer.masksToBounds = true

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

        titleLabel.font = .boldSystemFont(ofSize: 42)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 16 * 2),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16 * 2)
        ])
        
        [leftArrow, rightArrow].forEach {
            $0.tintColor = .white
            $0.alpha = 0.7
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            leftArrow.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            leftArrow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            leftArrow.widthAnchor.constraint(equalToConstant: 16 * 1.5),
            leftArrow.heightAnchor.constraint(equalToConstant: 24 * 1.5),

            rightArrow.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightArrow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            rightArrow.widthAnchor.constraint(equalToConstant: 16 * 1.5),
            rightArrow.heightAnchor.constraint(equalToConstant: 24 * 1.5)
        ])
    }
    
    override func configure(with item: NewsItem) {
        titleLabel.text = item.title
    }
}

