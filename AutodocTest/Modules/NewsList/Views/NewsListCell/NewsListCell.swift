//
//  NewsListCell.swift
//  AutodocTest
//
//  Created by Roman Komarov on 29.09.2026.
//

import UIKit

final class NewsListCell: UICollectionViewCell {
    // MARK: - Private
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = NewsListCell.placeholder
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .gray
        return imageView
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, dividerView])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private static let placeholder = UIImage(systemName: "photo.fill")
    
    private var currentImageUrl: String?
    private var imageLoadTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageLoadTask?.cancel()
        imageLoadTask = nil
        imageView.image = NewsListCell.placeholder
        titleLabel.text = nil
        currentImageUrl = nil
    }
    
    // MARK: - Configuration

    func configure(with item: NewsListCellData) {
        titleLabel.text = item.title
        currentImageUrl = item.imageUrl
        
        if let cached = ImageLoader.shared.cachedImage(from: item.imageUrl) {
            imageView.image = cached
            imageLoadTask?.cancel()
            imageLoadTask = nil
            return
        }
        
        imageView.image = NewsListCell.placeholder
        imageLoadTask?.cancel()
        
        let imageUrl = item.imageUrl
        imageLoadTask = Task { @MainActor [weak self] in
            let image = try? await ImageLoader.shared.loadImage(from: imageUrl)
            
            guard let self, !Task.isCancelled, currentImageUrl == imageUrl  else {
                return
            }
            
            imageView.image = image ?? NewsListCell.placeholder
        }
        
        dividerView.isHidden = !item.needDivider
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.backgroundColor = .white
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 2.0 / 3.0),
            dividerView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
}

// MARK: - ReuseIdentifier

extension NewsListCell {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}

// MARK: - Layout

extension NewsListCell {
    static func layout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300)
        )
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        
        let footerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(30)
        )
        
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.boundarySupplementaryItems = [footer]
        
        return UICollectionViewCompositionalLayout(section: section, configuration: config)
    }
}
