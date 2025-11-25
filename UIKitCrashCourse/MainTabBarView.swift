import UIKit

struct MainTabBarItem {
    let title: String
    let icon: UIImage?
}

protocol MainTabBarViewDelegate: AnyObject {
    func mainTabBar(_ tabBar: MainTabBarView, didSelect index: Int)
}

final class MainTabBarView: UIView {
    weak var delegate: MainTabBarViewDelegate?
    private let stackView = UIStackView()
    private var buttons: [UIButton] = []
    private var selectedIndex: Int = 0 {
        didSet { updateSelection() }
    }
    
    init(items: [MainTabBarItem]) {
        super.init(frame: .zero)
        setupView()
        setupButtons(items: items)
        updateSelection()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .systemBackground
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        layer.shadowRadius = 8
    }
    
    private func setupButtons(items: [MainTabBarItem]) {
        for (index, item) in items.enumerated() {
            let button = UIButton(type: .system)
            button.tag = index
            var config = UIButton.Configuration.plain()
            config.title = item.title
            config.image = item.icon
            config.imagePlacement = .top
            config.imagePadding = 4
            config.baseForegroundColor = .secondaryLabel
            button.configuration = config
            button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc private func didTapButton(_ sender: UIButton) {
        setSelectedIndex(sender.tag, notify: true)
    }
    
    func setSelectedIndex(_ index: Int, notify: Bool) {
        guard index >= 0, index < buttons.count else { return }
        selectedIndex = index
        if notify {
            delegate?.mainTabBar(self, didSelect: index)
        }
    }
    
    private func updateSelection() {
        for (idx, button) in buttons.enumerated() {
            let isSelected = (idx == selectedIndex)
            var config = button.configuration
            config?.baseForegroundColor = isSelected ? .label : .secondaryLabel
            button.configuration = config
        }
    }
}
