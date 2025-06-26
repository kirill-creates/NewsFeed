//
//  NewsAPIEndpoint.swift
//  NewsFeed
//
//  Created by Kirill on 26.06.2025.
//


enum NewsAPIEndpoint {
    case newsFeed(page: Int, count: Int)
    
    var path: String {
        switch self {
        case .newsFeed(let page, let count):
            return "/news/\(page)/\(count)"
        }
    }
}
