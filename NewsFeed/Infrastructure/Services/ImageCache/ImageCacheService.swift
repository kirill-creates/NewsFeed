//
//  ImageCacheService.swift
//  NewsFeed
//
//  Created by Kirill on 26.06.2025.
//

import UIKit


final class ImageCacheService: ImageCacheProtocol {
    // MARK: -
    static let shared = ImageCacheService()

    private init() {
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }

    // MARK: - Caches
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private lazy var diskCacheURL: URL = {
        let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent("temp")
    }()

    // MARK: - Public API
    func image(for url: URL) async throws -> UIImage {
        let key = url.absoluteString as NSString

        if let image = memoryCache.object(forKey: key) {
            return image
        }

        let diskURL = diskCacheURL.appendingPathComponent(String(key).safeFileName)
        
        if let data = try? Data(contentsOf: diskURL),
           let image = UIImage(data: data) {
            memoryCache.setObject(image, forKey: key, cost: data.count)
            return image
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode),
              let image = UIImage(data: data) else {
            throw ImageCacheError.invalidData
        }

        memoryCache.setObject(image, forKey: key, cost: data.count)
        
        try? store(image, for: diskURL)

        return image
    }

    func store(_ image: UIImage, for url: URL) throws {
        try fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true, attributes: nil)
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw ImageCacheError.invalidData
        }
        try data.write(to: url)
    }
}
