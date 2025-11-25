//
//  SettingsViewController.swift
//  UIKitCrashCourse
//
//  Created by Julyuniverse on 11/22/25.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

private extension SettingsViewController {
    
    func setup() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Settings"
        view.backgroundColor = .white
    }
}
