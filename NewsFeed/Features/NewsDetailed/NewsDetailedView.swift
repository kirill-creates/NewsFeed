//
//  NewsDetailedViewController.swift
//  NewsFeed
//
//  Created by Kirill on 25.06.2025.
//

import UIKit


final class NewsDetailedViewController: UIViewController {
    let viewModel: NewsDetailedViewModel

    init(viewModel: NewsDetailedViewModel) {
        self.viewModel = viewModel
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
