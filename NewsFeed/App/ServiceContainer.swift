//
//  ServiceContainer.swift
//  NewsFeed
//
//  Created by Kirill on 25.06.2025.
//


final class ServiceContainer {
    let newsAPI: NewsAPIProtocol
    let imageCache: ImageCacheProtocol
    let dataStorage: DataStorageProtocol
    
    static let shared = ServiceContainer(
        newsAPI: NewsAPI(),
        imageCache: ImageCacheService(),
        dataStorage: DataStorage()
    )
    
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
