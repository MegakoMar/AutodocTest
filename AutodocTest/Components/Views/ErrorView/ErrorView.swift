//
//  ErrorView.swift
//  AutodocTest
//
//  Created by Roman Komarov on 01.10.2026.
//

import UIKit

final class ErrorView: UIView {
    // MARK: - Private
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var actionButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = L10n.Button.retry
        configuration.contentInsets = .init(top: 10, leading: 16, bottom: 10, trailing: 16)
        configuration.baseBackgroundColor = .red
        configuration.baseForegroundColor = .white
        
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, messageLabel, actionButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var action: (() -> Void)?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func congigure(with data: ErrorViewData) {
        messageLabel.text = data.message
        action = data.action
        actionButton.isHidden = action == nil
        imageView.image = UIImage(systemName: data.type == .error ? "exclamationmark.circle" : "list.bullet.rectangle.portrait")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .white
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 250),
            imageView.heightAnchor.constraint(equalToConstant: 250),
        ])
    }
    
    @objc
    private func didTapButton() {
        action?()
    }
}
