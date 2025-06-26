//
//  ImageCacheProtocol.swift
//  NewsFeed
//
//  Created by Kirill on 26.06.2025.
//

import UIKit


protocol ImageCacheProtocol {
    func image(for url: URL) async throws -> UIImage
    func store(_ image: UIImage, for url: URL) throws
}
