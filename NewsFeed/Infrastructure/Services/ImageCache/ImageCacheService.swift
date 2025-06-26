//
//  ImageCacheService.swift
//  NewsFeed
//
//  Created by Kirill on 26.06.2025.
//

import UIKit


final class ImageCacheService: ImageCacheProtocol {
    // MARK: -

    init(maxMemory: Int = 50 * 1024 * 1024, // 50 MB
         maxDisk: Int = 50 * 1024 * 1024, // 50 MB
         maxAgeDays: Int = 5
    ) {
        self.maxDisk = maxDisk
        self.maxAgeDays = maxAgeDays
        
        memoryCache.totalCostLimit = maxMemory
        runDiskAutoCleanup()
    }

    private var maxDisk: Int
    private let maxAgeDays: Int
    
    // MARK: - Caches
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private lazy var diskCacheDirectoryURL: URL = {
        let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let directory = url.appendingPathComponent("temp", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }()

    // MARK: - Public API
    
    func image(for url: URL) async throws -> UIImage {
        let key = url.absoluteString as NSString

        if let image = memoryCache.object(forKey: key) {
            return image
        }

        let diskURL = diskCacheDirectoryURL.appendingPathComponent(String(key).safeFileName)
        
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
        
        try? store(image, as: diskURL)

        return image
    }

    func store(_ image: UIImage, as fileURL: URL) throws {
        try fileManager.createDirectory(at: diskCacheDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        guard let data = image.pngData() else {
            throw ImageCacheError.invalidData
        }
        try data.write(to: fileURL)
    }
    
    // MARK: - Disk cache cleanup
    
    private func runDiskAutoCleanup() {
        Task.detached { [weak self] in
            guard let self, !Task.isCancelled  else { return }
            while true {
                if Task.isCancelled { break }
                self.cleanUpDiskCache(maxSize: maxDisk, maxAgeDays: maxAgeDays)
                try? await Task.sleep(nanoseconds: 60 * 60 * 1_000_000_000) // 1 hour
            }
        }
    }

    private func cleanUpDiskCache(maxSize: Int, maxAgeDays: Int) {
        let resourceKeys: Set<URLResourceKey> = [.contentAccessDateKey, .totalFileAllocatedSizeKey]
        let expirationDate = Calendar.current.date(byAdding: .day, value: -maxAgeDays, to: Date()) ?? Date()

        guard let fileURLs = try? fileManager.contentsOfDirectory(at: diskCacheDirectoryURL, includingPropertiesForKeys: Array(resourceKeys)) else {
            return
        }

        var totalSize = 0
        var fileInfos: [(url: URL, size: Int, lastAccess: Date)] = []

        for url in fileURLs {
            guard let resourceValues = try? url.resourceValues(forKeys: resourceKeys),
                  let fileSize = resourceValues.totalFileAllocatedSize,
                  let accessDate = resourceValues.contentAccessDate ?? resourceValues.creationDate else {
                continue
            }

            if accessDate < expirationDate {
                try? fileManager.removeItem(at: url)
                continue
            }

            totalSize += fileSize
            fileInfos.append((url, fileSize, accessDate))
        }

        if totalSize > maxSize {
            let sorted = fileInfos.sorted(by: { $0.lastAccess < $1.lastAccess }) // LRU

            for file in sorted {
                try? fileManager.removeItem(at: file.url)
                totalSize -= file.size

                if totalSize <= maxSize {
                    break
                }
            }
        }
    }
}
