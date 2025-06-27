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
    @Published private var pagesCount = 1
    
    var newsListPublisher: Published<NewsList?>.Publisher { $newsList }
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorMessagePublisher: Published<String?>.Publisher { $errorMessage }
    var pagesCountPublisher: Published<Int>.Publisher { $pagesCount }
    
    private let newsAPI: NewsAPIProtocol
    private let imageCache: ImageCacheProtocol
    private let dataStorage: DataStorageProtocol
    
    private let pageSize = 30
    private var currentPage = 1
    
    init(
        newsAPI: NewsAPIProtocol,
        imageCache: ImageCacheProtocol,
        dataStorage: DataStorageProtocol
    ) {
        self.newsAPI = newsAPI
        self.imageCache = imageCache
        self.dataStorage = dataStorage
    }
    
    func onViewDidLoad() {
        loadCurrentPage()
    }
    
    func loadNextPage() {
        guard currentPage < pagesCount else { return }
        currentPage += 1
        loadCurrentPage()
    }
    
    func image(for item: NewsItem) async -> UIImage? {
        guard let url = URL(string: item.titleImageUrl) else { return nil }
        
        do {
            return try await imageCache.image(for: url)
        } catch {
            print("⚠️ Image load error: \(error)")
        }
        
        return nil
    }
    
    private func loadCurrentPage() {
        Task { [weak self] in
            guard let self else { return }
            await self.loadPage(page: currentPage)
        }
    }
    
    private func loadPage(page: Int) async {
        isLoading = true
        defer {
            isLoading = false
            newsList = dataStorage.load(page: page)
            calculatePagesCount()
        }
        
        do {
            let newsList = try await newsAPI.fetchNewsList(page: page, count: pageSize)
            dataStorage.save(newsList, page: page)
            self.newsList = newsList
        } catch {
            handle(error)
            newsList = dataStorage.load(page: page)
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
