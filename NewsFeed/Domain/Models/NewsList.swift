//
//  NewsList.swift
//  NewsFeed
//
//  Created by Kirill on 25.06.2025.
//


struct NewsList: Decodable {
    let news: [NewsItem]
    let totalCount: Int
}
