//
//  NewsFeedViewController.swift
//  NewsFeed
//
//  Created by Kirill on 25.06.2025.
//

import UIKit


final class NewsFeedViewController: UIViewController {
    let viewModel: NewsFeedViewModel
    let onItemSelected: (NewsItem) -> Void

    init(viewModel: NewsFeedViewModel, onItemSelected: @escaping (NewsItem) -> Void) {
        self.viewModel = viewModel
        self.onItemSelected = onItemSelected
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}
