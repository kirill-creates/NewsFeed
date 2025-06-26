//
//  String+.swift
//  NewsFeed
//
//  Created by Kirill on 26.06.2025.
//


extension String {
    var safeFileName: String {
        return self
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
    }
}
