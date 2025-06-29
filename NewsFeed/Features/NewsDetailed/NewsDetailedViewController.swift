//
//  NewsDetailedViewController.swift
//  NewsFeed
//
//  Created by Kirill on 25.06.2025.
//

import UIKit


final class NewsDetailedViewController: UIViewController {
    private let viewModel: NewsDetailedViewModel
    
    private let scrollView = UIScrollView()
    private let overlayView = UIView()
    private let contentStack = UIStackView()
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()
    private let categoryLabel = UILabel()
    private let openButton = UIButton(type: .system)

    init(viewModel: NewsDetailedViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        configure()
        loadImage()
    }

    private func setupNavigationBar() {
        view.backgroundColor = .black
        
        var config = UIButton.Configuration.filled()
        config.title = "Закрыть"
        config.baseBackgroundColor = .systemRed
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        config.titleAlignment = .center
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .boldSystemFont(ofSize: 16)
            return outgoing
        }
        let closeButton = UIButton(type: .system)
        closeButton.configuration = config
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
    }

    private func setupUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlayView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8)
        ])
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: overlayView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor)
        ])
        
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
        
        [titleLabel, descriptionLabel, dateLabel, categoryLabel].forEach {
            $0.textColor = .white
            $0.numberOfLines = 0
            contentStack.addArrangedSubview($0)
        }
        
        titleLabel.font = .boldSystemFont(ofSize: 24)
        descriptionLabel.font = .systemFont(ofSize: 18)
        dateLabel.font = .systemFont(ofSize: 14)
        categoryLabel.font = .systemFont(ofSize: 14)
        
        var config = UIButton.Configuration.filled()
        config.title = "Открыть новость на сайте"
        config.baseBackgroundColor = .systemRed
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        config.titleAlignment = .center
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .boldSystemFont(ofSize: 16)
            return outgoing
        }

        openButton.configuration = config
        openButton.addTarget(self, action: #selector(openSiteTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(openButton)
    }

    private func configure() {
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        dateLabel.text = "🗓 \(viewModel.publishedDate)"
        categoryLabel.text = "📌 \(viewModel.categoryType)"
    }

    private func loadImage() {
        Task {
            if let image = await viewModel.image() {
                imageView.image = image
            }
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func openSiteTapped() {
        guard let url = viewModel.fullUrl else { return }
        UIApplication.shared.open(url)
    }
}
