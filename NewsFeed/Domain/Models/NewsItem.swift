//
//  NewsItem.swift
//  NewsFeed
//
//  Created by Kirill on 25.06.2025.
//


struct NewsItem: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let description: String
    let publishedDate: String
    let url: String
    let fullUrl: String
    let titleImageUrl: String?
    let categoryType: String
}
