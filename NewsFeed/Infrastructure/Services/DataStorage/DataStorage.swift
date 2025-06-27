//
//  DataStorage.swift
//  NewsFeed
//
//  Created by Kirill on 26.06.2025.
//

import Foundation


final class DataStorage: DataStorageProtocol {
    private let defaults = UserDefaults.standard
    private let keyPrefix = "news_feed_list"
    
    private func pageKey(_ page: Int) -> String {
        return "\(keyPrefix)_\(page)"
    }
    
    func save(_ list: NewsList, page: Int) {
        do {
            let data = try JSONEncoder().encode(list)
            defaults.set(data, forKey: pageKey(page))
        } catch {
            print("DataStorage: Failed to encode NewsList — \(error)")
        }
    }
    
    func load(page: Int) -> NewsList? {
        guard let data = defaults.data(forKey: pageKey(page)),
              let feed = try? JSONDecoder().decode(NewsList.self, from: data) else {
            return nil
        }
        return feed
    }
    
    func clear() {
        for (key, _) in defaults.dictionaryRepresentation() {
            if key.hasPrefix(keyPrefix) {
                defaults.removeObject(forKey: key)
            }
        }
    }
}
