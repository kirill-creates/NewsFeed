//
//  Coordinator.swift
//  NewsFeed
//
//  Created by Kirill on 26.06.2025.
//

import UIKit


protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}
