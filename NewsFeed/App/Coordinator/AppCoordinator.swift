//
//  AppCoordinator.swift
//  NewsFeed
//
//  Created by Kirill on 25.06.2025.
//

import UIKit


final class AppCoordinator: Coordinator {
    private let serviceContainer: ServiceContainer
    
    let window: UIWindow
    let navigationController: UINavigationController
    
    init(window: UIWindow, serviceContainer: ServiceContainer) {
        self.window = window
        self.navigationController = UINavigationController()
        self.serviceContainer = serviceContainer
    }
    
    func start() {
        let viewModel = NewsFeedViewModel(
            newsAPI: serviceContainer.newsAPI,
            imageCache: serviceContainer.imageCache,
            dataStorage: serviceContainer.dataStorage
        )
        
        let viewController = NewsFeedViewController(viewModel: viewModel) { [weak self] newsItem in
            self?.showDetails(for: newsItem)
        }

        navigationController.viewControllers = [viewController]
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    private func showDetails(for newsItem: NewsItem) {
        let viewModel = NewsDetailedViewModel(newsItem: newsItem)
        let vc = NewsDetailedViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
}
