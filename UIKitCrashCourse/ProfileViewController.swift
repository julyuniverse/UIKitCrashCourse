//
//  ProfileViewController.swift
//  UIKitCrashCourse
//
//  Created by Julyuniverse on 12/1/25.
//

import UIKit

class ProfileViewController: UIViewController {
    private let profileItemView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupProfileItemView()
    }
}

private extension ProfileViewController {
    
    func setupProfileItemView() {
        profileItemView.backgroundColor = .systemMint
        view.addSubview(profileItemView)
        profileItemView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileItemView.topAnchor.constraint(equalTo: view.topAnchor),
            profileItemView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileItemView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileItemView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
