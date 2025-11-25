//
//  PersonCollectionViewCell.swift
//  UIKitCrashCourse
//
//  Created by July universe on 11/22/25.
//

import UIKit

protocol PersonCollectionViewCellDelegate: AnyObject {
    func didTapSubscribe()
}

class PersonCollectionViewCell: UICollectionViewCell {
    private var vw: PersonView?
    weak var delegate: PersonCollectionViewCellDelegate?
    var item: PersonResponse? {
        didSet {
            guard let firstName = item?.firstName,
                  let lastName = item?.lastName,
                  let email = item?.email else { return }
            vw?.set(name: "\(firstName) \(lastName)", email: email)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension PersonCollectionViewCell {
    
    func setup() {
        guard vw == nil else { return }
        vw = PersonView { [weak self] in
            self?.delegate?.didTapSubscribe()
        }
        contentView.addSubview(vw!)
        NSLayoutConstraint.activate([
            vw!.topAnchor.constraint(equalTo: contentView.topAnchor),
            vw!.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            vw!.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            vw!.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
}
