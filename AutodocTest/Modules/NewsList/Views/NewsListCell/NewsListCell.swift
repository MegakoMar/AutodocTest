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
        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.backgroundColor = .white
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 2.0 / 3.0),
        ])
    }
}

// MARK: - ReuseIdentifier

extension NewsListCell {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}
