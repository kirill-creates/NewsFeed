//
//  NewsAPI.swift
//  NewsFeed
//
//  Created by Kirill on 26.06.2025.
//
import Foundation

private func makeURL(for endpoint: NewsAPIEndpoint) -> URL? {
    return URL(string: NewsAPIConst.baseURL + endpoint.path)
}

final class NewsAPI: NewsAPIProtocol {
    func fetchNewsList(page: Int, count: Int) async throws -> NewsList {
        guard let url = makeURL(for: .newsFeed(page: page, count: count)) else {
            throw NewsAPIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NewsAPIError.requestFailed(statusCode: -1)
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw NewsAPIError.requestFailed(statusCode: httpResponse.statusCode)
            }
            
            do {
                return try JSONDecoder().decode(NewsList.self, from: data)
            } catch {
                throw NewsAPIError.decodingFailed
            }
        } catch {
            throw NewsAPIError.error(error)
        }
   }
}
