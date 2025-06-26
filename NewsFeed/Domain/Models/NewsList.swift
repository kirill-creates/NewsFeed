//
//  NewsList.swift
//  NewsFeed
//
//  Created by Kirill on 25.06.2025.
//


struct NewsList: Codable {
    let news: [NewsItem]
    let totalCount: Int
}
