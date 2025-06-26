//
//  NewsFeedViewModel.swift
//  NewsFeed
//
//  Created by Kirill on 25.06.2025.
//

import Foundation
import Combine


final class NewsFeedViewModel: ObservableObject {
    private let newsAPI: NewsAPIProtocol
    private let imageCache: ImageCacheProtocol
    private let dataStorage: DataStorageProtocol
    
    init(
        newsAPI: NewsAPIProtocol,
        imageCache: ImageCacheProtocol,
        dataStorage: DataStorageProtocol
    ) {
        self.newsAPI = newsAPI
        self.imageCache = imageCache
        self.dataStorage = dataStorage
    }
}
