//
//  NewsDetailedViewModel.swift
//  NewsFeed
//
//  Created by Kirill on 25.06.2025.
//

import UIKit
import Combine


final class NewsDetailedViewModel: NewsDetailedViewModelProtocol {
    private let newsItem: NewsItem
    private let imageCache: ImageCacheProtocol
    
    var title: String {
        newsItem.title
    }
    
    var description: String {
        newsItem.description
    }
    
    var publishedDate: String {
        DateFormatter.newsDisplayFormatter.string(
            from: DateFormatter.newsParsingFormatter.date(from: newsItem.publishedDate) ?? Date()
        )
    }
    
    var categoryType: String {
        newsItem.categoryType
    }
    
    var fullUrl: URL? {
        URL(string: newsItem.fullUrl)
    }
    
    func image() async -> UIImage? {
        guard let titleImageUrl = newsItem.titleImageUrl,
              let url = URL(string:titleImageUrl) else {
            return nil
        }
        
        return try? await imageCache.image(for: url)
    }

    init(
        newsItem: NewsItem,
        imageCache: ImageCacheProtocol
    ) {
        self.newsItem = newsItem
        self.imageCache = imageCache
    }
}
