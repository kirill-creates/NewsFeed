//
//  NewsDetailedViewModelProtocol.swift
//  NewsFeed
//
//  Created by Kirill on 29.06.2025.
//

protocol NewsDetailedViewModelProtocol: AnyObject {
    var title: String { get }
    var description: String { get }
    var publishedDate: String { get }
    var categoryType: String { get }
}
