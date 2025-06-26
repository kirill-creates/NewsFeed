//
//  NewsAPIProtocol.swift
//  NewsFeed
//
//  Created by Kirill on 25.06.2025.
//


protocol NewsAPIProtocol {
    func fetchNewsList(page: Int, count: Int) async throws -> NewsList
}
