//
//  NewsFeedViewModel.swift
//  NewsFeed
//
//  Created by Kirill on 25.06.2025.
//

import Combine
import UIKit

final class NewsFeedViewModel: NewsFeedViewModelProtocol {
    @Published private var newsList: NewsList?
    @Published private var isLoading = false
    @Published private var errorMessage: String?
    
    var newsListPublisher: Published<NewsList?>.Publisher { $newsList }
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorMessagePublisher: Published<String?>.Publisher { $errorMessage }
    
    private let newsAPI: NewsAPIProtocol
    private let imageCache: ImageCacheProtocol
    private let dataStorage: DataStorageProtocol
    
    private let loadGate = PageLoadGate()
    
    private var pagesCount = 0
    private let pageSize = 30
    private var currentPage = 0
    
    init(
        newsAPI: NewsAPIProtocol,
        imageCache: ImageCacheProtocol,
        dataStorage: DataStorageProtocol
    ) {
        self.newsAPI = newsAPI
        self.imageCache = imageCache
        self.dataStorage = dataStorage
    }
    
    var mainAutoScrollInterval: TimeInterval { 9 }
    var categoryAutoScrollInterval: TimeInterval { 3 }
    
    func onViewDidLoad() {
        loadNextPage()
    }
    
    func refresh() {
        currentPage = 0
        newsList = nil
        loadNextPage()
    }
    
    func loadNextPage() {
        guard pagesCount == 0 || pagesCount > currentPage else { return }
        Task {
            await loadGate.performLoad(page: currentPage + 1) { [weak self] page in
                await self?.loadPage(page: page)
            }
        }
    }
    
    func image(for item: NewsItem) async -> UIImage? {
        guard let titleImageUrl = item.titleImageUrl,
              let url = URL(string:titleImageUrl) else {
            return nil
        }
        
        return try? await imageCache.image(for: url)
    }
    
    private func loadPage(page: Int) async {
        isLoading = true
        defer {
            isLoading = false
            calculatePagesCount()
        }
        
        do {
            let newsList = try await newsAPI.fetchNewsList(page: page, count: pageSize)
            dataStorage.save(newsList, page: page)
            
            if var currentList = self.newsList {
                currentList.news.append(contentsOf: newsList.news)
                self.newsList = currentList
            } else {
                self.newsList = newsList
            }
            
            currentPage = page
        } catch {
            handle(error)
            newsList = dataStorage.load(page: page)
#if DEBUG
            print("❌ Error occurred: \(error)")
#endif
        }
    }
    
    private func calculatePagesCount() {
        guard let newsList else { return }
        pagesCount = (newsList.totalCount + pageSize - 1) / pageSize
    }
    
    private func handle(_ error: Error) {
        if let apiError = error as? NewsAPIError {
            errorMessage = apiError.errorMessage
        } else {
            errorMessage = error.localizedDescription
        }
    }
}

fileprivate actor PageLoadGate {
    private var isLoading = false

    func performLoad(page: Int, loader: @escaping (Int) async -> Void) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        await loader(page)
    }
}
