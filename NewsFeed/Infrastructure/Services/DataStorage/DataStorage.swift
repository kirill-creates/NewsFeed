//
//  DataStorage.swift
//  NewsFeed
//
//  Created by Kirill on 26.06.2025.
//

import Foundation


final class DataStorage: DataStorageProtocol {
    private let defaults = UserDefaults.standard
    private let key = "news_feed_list"
    
    private func clear() {
        defaults.removeObject(forKey: key)
    }

    func save(_ list: NewsList) {
        clear()
        guard let data = try? JSONEncoder().encode(list) else {
            return
        }
        defaults.set(data, forKey: key)
    }

    func load() -> NewsList? {
        guard let data = defaults.data(forKey: key),
              let feed = try? JSONDecoder().decode(NewsList.self, from: data) else {
            return nil
        }
        return feed
    }
}
