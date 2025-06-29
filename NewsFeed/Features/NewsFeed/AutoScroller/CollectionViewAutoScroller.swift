//
//  CollectionViewAutoScroller.swift
//  NewsFeed
//
//  Created by Kirill on 27.06.2025.
//

import UIKit


final class CollectionViewAutoScroller {
    private weak var collectionView: UICollectionView?
    private let section: Int
    private let interval: TimeInterval
    private var timer: Timer?
    private var currentIndex = 0
    private let step: Int

    init(
        collectionView: UICollectionView,
        section: Int,
        step: Int = 1,
        interval: TimeInterval = 3.0
    ) {
        self.collectionView = collectionView
        self.section = section
        self.step = step
        self.interval = interval
    }

    func start() {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.scrollToNextItem()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func scrollToNextItem() {
        guard let collectionView else { return }
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        guard numberOfItems > 0 else { return }

        currentIndex += step
        if currentIndex >= numberOfItems {
            currentIndex = 0
        }

        let indexPath = IndexPath(item: currentIndex, section: section)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}
