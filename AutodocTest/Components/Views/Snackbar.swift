//
//  Snackbar.swift
//  AutodocTest
//
//  Created by Roman Komarov on 07.10.2026.
//

import UIKit

final class Snackbar: UIView {
    // MARK: - Private
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    static func show(message: String, in view: UIView, duration: TimeInterval = 3.0) {
        let snackbar = Snackbar()
        snackbar.messageLabel.text = message
        snackbar.alpha = 0
        
        view.addSubview(snackbar)
        snackbar.setupConstraints(in: view)
        
        UIView.animate(withDuration: 0.3) {
            snackbar.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: []) {
                snackbar.alpha = 0
            } completion: { _ in
                snackbar.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = UIColor.systemRed
        layer.cornerRadius = 8
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }
    
    private func setupConstraints(in superview: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}
