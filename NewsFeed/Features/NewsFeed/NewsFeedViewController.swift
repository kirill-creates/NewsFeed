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
    private var mainAutoScroller: CollectionViewAutoScroller?
    private var categoryAutoScroller: CollectionViewAutoScroller?
    private var mainItems: [NewsItem] = []  {
        didSet {
            if mainItems.count > 0 {
                mainAutoScroller?.start()
            } else {
                mainAutoScroller?.stop()
            }
        }
    }
    private var categoryItems: [NewsItem] = [] {
        didSet {
            if mainItems.count > 0 {
                categoryAutoScroller?.start()
            } else {
                categoryAutoScroller?.stop()
            }
        }
    }
    private var isLoading = false
    
    private lazy var collectionView: UICollectionView = {
        UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
    }()
    
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    private let onItemSelected: (NewsItem) -> Void
    private var currentAutoScrollIndex = 0
    
    enum Section: Int, CaseIterable {
        case main
        case category
        case list
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, NewsItem>?

    init(viewModel: NewsFeedViewModelProtocol, onItemSelected: @escaping (NewsItem) -> Void) {
        self.viewModel = viewModel
        self.onItemSelected = onItemSelected
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        configureDataSource()
        bindViewModel()
        viewModel.onViewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mainAutoScroller = CollectionViewAutoScroller(
            collectionView: collectionView,
            section: 0,
            interval: viewModel.mainAutoScrollInterval
        )
        
        categoryAutoScroller = CollectionViewAutoScroller(
            collectionView: collectionView,
            section: 1,
            step: 3,
            interval: viewModel.categoryAutoScrollInterval
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainAutoScroller?.stop()
        categoryAutoScroller?.stop()
    }
    
    private func setupNavigationBar() {
        let logoImage = UIImage(named: "AppLogo")
        let imageView = UIImageView(image: logoImage)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 125).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let logoItem = UIBarButtonItem(customView: imageView)
        navigationItem.leftBarButtonItem = logoItem

        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .gray

        navigationItem.titleView = loadingIndicator

        var config = UIButton.Configuration.filled()
        config.title = "Обновить"
        config.baseBackgroundColor = .systemRed
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        config.titleAlignment = .center
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .boldSystemFont(ofSize: 16)
            return outgoing
        }
        let refreshButton = UIButton(type: .system)
        refreshButton.configuration = config
        refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: refreshButton)
    }
    
    private func setupUI() {
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
        //collectionView.dataSource = self
        collectionView.delegate = self

        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.newsListPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] list in
                guard let self, let list else { return }
                self.updateSnapshot(with: list.news)
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
            .sink { [weak self] loading in
                guard let self else { return }
                if loading {
                    loadingIndicator.startAnimating()
                } else {
                    loadingIndicator.stopAnimating()
                }
                isLoading = loading
            }
            .store(in: &cancellables)
    }
    
    private func presentError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Закрыть", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func refreshTapped() {
        viewModel.refresh()
    }
}

// MARK: - UICollectionViewDelegate

extension NewsFeedViewController: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        mainAutoScroller?.stop()
        categoryAutoScroller?.stop()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if mainItems.count > 0 {
            mainAutoScroller?.start()
        }
        if categoryItems.count > 0 {
            categoryAutoScroller?.start()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource?.itemIdentifier(for: indexPath) else {
            return
        }
        
        onItemSelected(item)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isLoading else { return }
        guard let collectionView = scrollView as? UICollectionView, let dataSource else { return }
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        let visibleSection2 = visibleIndexPaths.filter { $0.section == 2 }
        
        guard !visibleSection2.isEmpty else { return }
    
        let maxVisibleItem = visibleSection2.map { $0.item }.max() ?? 0
        let snapshot = dataSource.snapshot()
        let section2Items = snapshot.itemIdentifiers(inSection: .list)
        
        if maxVisibleItem >= section2Items.count - 2 {
            viewModel.loadNextPage()
        }
    }
}

// MARK: - Data Source

extension NewsFeedViewController {
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, NewsItem>(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, item in
                guard let self, let section = Section(rawValue: indexPath.section) else {
                    return UICollectionViewCell()
                }
                let cell: BaseItemCell
                switch section {
                case .main:
                    cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: MainItemCell.reuseIdentifier,
                        for: indexPath
                    ) as! MainItemCell
                case .category:
                    cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: CategoryItemCell.reuseIdentifier,
                        for: indexPath
                    ) as! CategoryItemCell
                case .list:
                    cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: ListItemCell.reuseIdentifier,
                        for: indexPath
                    ) as! ListItemCell
                }
                
                cell.configure(with: item)
                cell.task?.cancel()
                cell.task = Task { [weak cell] in
                    let image = await self.viewModel.image(for: item)
                    if Task.isCancelled { return }
                    await MainActor.run {
                        guard let image else { return }
                        cell?.imageView.image = image
                    }
                }
                return cell
            }
        )
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: NewsFeedSectionHeaderView.reuseIdentifier,
                for: indexPath
            ) as! NewsFeedSectionHeaderView

            switch Section(rawValue: indexPath.section)! {
            case .main: header.setTitle("Главное")
            case .category: header.setTitle("Рубрики")
            case .list: header.setTitle("Новости")
            }
            return header
        }
    }
    
    private func updateSnapshot(with news: [NewsItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, NewsItem>()

        snapshot.appendSections(Section.allCases)

        mainItems = Array(news.prefix(5))
        categoryItems = Array(news.dropFirst(5).prefix(15))
        let listItems = Array(news.dropFirst(20))

        snapshot.appendItems(mainItems, toSection: .main)
        snapshot.appendItems(categoryItems, toSection: .category)
        snapshot.appendItems(listItems, toSection: .list)

        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Layout

extension NewsFeedViewController {
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
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
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
}
