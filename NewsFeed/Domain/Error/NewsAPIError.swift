//
//  NewsAPIError.swift
//  NewsFeed
//
//  Created by Kirill on 26.06.2025.
//

import Foundation


enum NewsAPIError: Error {
    case invalidURL
    case requestFailed(statusCode: Int)
    case decodingFailed
    case noData
    case error(Error)
    
    var errorMessage: String {
        switch self {
        case .invalidURL:
            return "Невалидный URL"
        case .requestFailed(statusCode: let code):
            return "Ошибка запроса, код: \(code)"
        case .decodingFailed:
            return "Ошибка декодироваия."
        case .noData:
            return "Ошбика получения данных."
        case .error(let error):
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet:
                    return "Нет подключения к интернету."
                case .timedOut:
                    return "Превышено время ожидания."
                default:
                    return "URL ошибка: \(urlError.code)"
                }
            } else {
                return "\(error.localizedDescription)"
            }
        }
    }
}
