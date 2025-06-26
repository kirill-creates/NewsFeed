//
//  DataStorage.swift
//  NewsFeed
//
//  Created by Kirill on 26.06.2025.
//

import Foundation


final class DataStorage: DataStorageProtocol {
    private let defaults = UserDefaults.standard
    private static let key = "news_feed_list"
    
    func save(_ list: NewsList) {
        do {
            let data = try JSONEncoder().encode(list)
            defaults.set(data, forKey: Self.key)
        } catch {
            print("DataStorage: Failed to encode NewsList — \(error)")
        }
    }
    
    func load() -> NewsList? {
        guard let data = defaults.data(forKey: Self.key),
              let feed = try? JSONDecoder().decode(NewsList.self, from: data) else {
            return nil
        }
        return feed
    }
}
