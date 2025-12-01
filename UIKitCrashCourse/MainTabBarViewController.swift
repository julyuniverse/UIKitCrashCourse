import UIKit

final class MainTabBarViewController: UIViewController {
    private let contentView = UIView()
    private var tabBarHeightConstraint: NSLayoutConstraint!
    private lazy var tabBarItems: [MainTabBarItem] = [
        .init(title: "Person", icon: UIImage(systemName: "person")),
        .init(title: "검색", icon: UIImage(systemName: "magnifyingglass")),
        .init(title: "Settings", icon: UIImage(systemName: "gearshape")),
        .init(title: "Profile", icon: UIImage(systemName: "person.crop.circle"))
    ]
    private lazy var tabBarView = MainTabBarView(items: tabBarItems)
    private lazy var viewControllers: [UIViewController] = [
        PeopleViewController(),
        ListViewController(), // 스크롤 확인용
        UINavigationController(rootViewController: SettingsViewController())
    ]
    private var currentIndex: Int = 0
    // Profile 탭 인덱스 (마지막)
    private var profileTabIndex: Int { tabBarItems.count - 1 }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tabBarView.delegate = self
        layout()
        switchTo(index: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 버튼들이 들어갈 기본 높이(탭바 자체 높이)
        let baseHeight: CGFloat = 60
        let bottomInset = view.safeAreaInsets.bottom
        tabBarHeightConstraint.constant = baseHeight + bottomInset
    }
    
    private func layout() {
        view.addSubview(contentView)
        view.addSubview(tabBarView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        tabBarHeightConstraint = tabBarView.heightAnchor.constraint(equalToConstant: 60)
        
        NSLayoutConstraint.activate([
            // 탭바는 하단에 고정
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBarHeightConstraint,
            
            // 컨텐츠는 탭바 위까지
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: tabBarView.topAnchor)
        ])
    }
    
    private func switchTo(index: Int) {
        let newVC = viewControllers[index]
        let oldVC = children.first
        
        // 기존 VC 제거
        if let oldVC = oldVC {
            oldVC.willMove(toParent: nil)
            oldVC.view.removeFromSuperview()
            oldVC.removeFromParent()
        }
        
        // 새 VC 추가
        addChild(newVC)
        contentView.addSubview(newVC.view)
        newVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            newVC.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            newVC.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            newVC.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            newVC.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        newVC.didMove(toParent: self)
        currentIndex = index
    }
    
    // 프로필 시트
    private func presentProfileSheet() {
        let profileVC = ProfileViewController()
        profileVC.modalPresentationStyle = .pageSheet
        
        if let sheet = profileVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()] // 중간/전체 두 단계
            sheet.prefersGrabberVisible = true // 위에 손잡이 표시
        }
        
        present(profileVC, animated: true)
    }
}

extension MainTabBarViewController: MainTabBarViewDelegate {
    
    func mainTabBar(_ tabBar: MainTabBarView, didSelect index: Int) {
        if index == profileTabIndex {
            presentProfileSheet()
            
            // 선택 상태는 원래 탭으로 되돌리고 싶다면
            tabBarView.setSelectedIndex(currentIndex, notify: false)
            return
        }
        
        // 나머지 탭은 기존처럼 화면 전환
        guard index != currentIndex else { return }
        switchTo(index: index)
    }
}

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
