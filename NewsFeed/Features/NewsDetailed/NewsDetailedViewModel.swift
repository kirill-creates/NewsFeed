//
//  NewsDetailedViewModel.swift
//  NewsFeed
//
//  Created by Kirill on 25.06.2025.
//

import Combine


final class NewsDetailedViewModel: ObservableObject {
    private let newsItem: NewsItem
    
    init(newsItem: NewsItem) {
        self.newsItem = newsItem
    }
}


