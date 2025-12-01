import UIKit

final class MainTabBarController: UIViewController {
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

extension MainTabBarController: MainTabBarViewDelegate {
    
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
