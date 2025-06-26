//
//  DataStorageProtocol.swift
//  NewsFeed
//
//  Created by Kirill on 26.06.2025.
//


protocol DataStorageProtocol {
    func save(_ list: NewsList)
    func load() -> NewsList?
}
