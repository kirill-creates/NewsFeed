//
//  NewsFeedViewController.swift
//  NewsFeed
//
//  Created by Kirill on 25.06.2025.
//

import UIKit
import Combine


final class NewsFeedViewController: UIViewController {
    private let viewModel: NewsFeedViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private var items: [NewsItem] = []
    
    private lazy var collectionView: UICollectionView = {
        UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .gray
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let onItemSelected: (NewsItem) -> Void

    init(viewModel: NewsFeedViewModel, onItemSelected: @escaping (NewsItem) -> Void) {
        self.viewModel = viewModel
        self.onItemSelected = onItemSelected
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.onViewDidLoad()
    }
    
    private func setupUI() {
        title = "НОВОСТИ"
        view.backgroundColor = .systemBackground

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(
            NewsFeedSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: NewsFeedSectionHeaderView.reuseIdentifier
        )
        collectionView.register(MainItemCell.self, forCellWithReuseIdentifier: MainItemCell.reuseIdentifier)
        collectionView.register(CategoryItemCell.self, forCellWithReuseIdentifier: CategoryItemCell.reuseIdentifier)
        collectionView.register(ListItemCell.self, forCellWithReuseIdentifier: ListItemCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self

        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.newsListPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] list in
                guard let self, let list else { return }
                self.items = list.news
                self.collectionView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.errorMessagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self, let message else { return }
                self.presentError(message)
            }
            .store(in: &cancellables)
        
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self else { return }
                isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
            }
            .store(in: &cancellables)
        
        viewModel.pagesCountPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pages in
                //self?.pagesCount = pages
            }
            .store(in: &cancellables)
    }
    
    private func presentError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Закрыть", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension NewsFeedViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return min(1, items.count)
        case 1:
            return min(10, items.count)
        default:
            return max(0, items.count)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard items.count > indexPath.item else {
            return UICollectionViewCell()
        }
        
        let cell: BaseItemCell?
        switch indexPath.section {
        case 0:
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MainItemCell.reuseIdentifier,
                for: indexPath
            ) as? MainItemCell
        case 1:
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CategoryItemCell.reuseIdentifier,
                for: indexPath
            ) as? CategoryItemCell
        default:
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ListItemCell.reuseIdentifier,
                for: indexPath
            ) as? ListItemCell
            break
        }
        
        guard let cell else {
            return UICollectionViewCell()
        }

        let item = items[indexPath.item]
        
        cell.titleLabel.text = item.title
        cell.task?.cancel()
        cell.task = Task { [weak cell] in
            let image = await viewModel.image(for: item)
            if Task.isCancelled { return }
            await MainActor.run {
                guard let image else { return }
                cell?.imageView.image = image
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: NewsFeedSectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as! NewsFeedSectionHeaderView
        
        let title: String
        switch indexPath.section {
        case 0: title = "Главное"
        case 1: title = "Рубрики"
        case 2: title = "Новости"
        default: title = ""
        }

        header.setTitle(title)
        return header
    }
}

// MARK: - UICollectionViewDelegate

extension NewsFeedViewController: UICollectionViewDelegate {

}

// MARK: - Layout

private func makeLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout { sectionIndex, environment in
        let containerHeight = environment.container.effectiveContentSize.height
        
        switch sectionIndex {
        case 0:
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(containerHeight * 0.2)
                ),
                subitems: [item]
            )
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .paging
            section.boundarySupplementaryItems = [makeHeader()]
            return section
            
        case 1:
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / CGFloat(3)),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(containerHeight * 0.2)
                ),
                subitems: [item]
            )
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            section.boundarySupplementaryItems = [makeHeader()]
            return section

        default:
            let item = NSCollectionLayoutItem(
                layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            )
            item.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(120)
                ),
                subitems: [item]
            )
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [makeHeader()]
            return section
        }
    }
    
    func makeHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(44)
        )
        
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}
