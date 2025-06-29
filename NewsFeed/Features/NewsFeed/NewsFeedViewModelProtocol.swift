//
//  Untitled.swift
//  NewsFeed
//
//  Created by Kirill on 26.06.2025.
//

import Combine
import UIKit


protocol NewsFeedViewModelProtocol: AnyObject {
    var newsListPublisher: Published<NewsList?>.Publisher { get }
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorMessagePublisher: Published<String?>.Publisher { get }
    var pagesCountPublisher: Published<Int>.Publisher { get }
    
    var mainAutoScrollInterval: TimeInterval { get }
    var categoryAutoScrollInterval: TimeInterval { get }
    
    func image(for item: NewsItem) async -> UIImage?
    
    func onViewDidLoad()
}
