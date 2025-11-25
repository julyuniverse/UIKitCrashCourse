//
//  PersonView.swift
//  UIKitCrashCourse
//
//  Created by July universe on 11/22/25.
//

import UIKit

class PersonView: UIView {
    private lazy var subscribeBtn: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Subscribe".uppercased()
        config.baseBackgroundColor = .red
        config.baseForegroundColor = .white
        config.buttonSize = .large
        config.cornerStyle = .medium
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didTapSubscribe), for: .touchUpInside)
        return btn
    }()
    private lazy var nameLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "John Doe"
        lbl.font = .systemFont(ofSize: 24, weight: .bold)
        return lbl
    }()
    private lazy var emailLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "john.doe@example.com"
        lbl.font = .systemFont(ofSize: 13, weight: .regular)
        return lbl
    }()
    private lazy var personStackVw: UIStackView = {
        let vw = UIStackView()
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.axis = .vertical
        vw.spacing = 8
        return vw
    }()
    private var action: () -> ()
    
    init(action: @escaping () -> ()) {
        self.action = action
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(name: String, email: String) {
        nameLbl.text = name
        emailLbl.text = email
    }
}

private extension PersonView {
    
    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .gray.withAlphaComponent(0.1)
        layer.cornerRadius = 8
        addSubview(personStackVw)
        personStackVw.addArrangedSubview(nameLbl)
        personStackVw.addArrangedSubview(emailLbl)
        personStackVw.addArrangedSubview(subscribeBtn)
        NSLayoutConstraint.activate([
            personStackVw.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            personStackVw.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            personStackVw.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            personStackVw.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8)
        ])
    }
    
    @objc func didTapSubscribe(sender: UIButton) {
        action()
    }
}
