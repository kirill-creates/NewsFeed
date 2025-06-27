//
//  BaseItemCell.swift
//  NewsFeed
//
//  Created by Kirill on 27.06.2025.
//

import UIKit

final class GradientView: UIView {
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
}

class BaseItemCell: UICollectionViewCell {
    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let gradientView = GradientView()
    
    var task: Task<Void, Never>? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        task = nil
        imageView.image = nil
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        fatalError("Must override setupUI in subclass")
    }
}
