//
//  NewsAPIError.swift
//  NewsFeed
//
//  Created by Kirill on 26.06.2025.
//


enum NewsAPIError: Error {
    case invalidURL
    case requestFailed(statusCode: Int)
    case decodingFailed
    case noData
    case unknown(Error)
}
