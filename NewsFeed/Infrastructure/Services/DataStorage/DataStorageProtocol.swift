//
//  DataStorageProtocol.swift
//  NewsFeed
//
//  Created by Kirill on 26.06.2025.
//


protocol DataStorageProtocol {
    func save(_ list: NewsList, page: Int)
    func load(page: Int) -> NewsList?
    func clear()
}
