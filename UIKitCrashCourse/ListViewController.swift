import UIKit

final class ListViewController: UIViewController {
    private let firstHeaderView = UIView()
    private let secondHeaderView = UIView()
    private let thirdHeaderView = UIView()
    private let refreshView = UIView()
    private let refreshLabel = UILabel()
    private let tableView = UITableView()
    private let items: [[String]] = (0..<10).map { section in
        (0..<10).map { row in
            "섹션 \(section) - 셀 \(row)"
        }
    }
    private let loadingIndicator: UIActivityIndicatorView = .init(style: .medium)
    private var isRefreshing = false
    private var lastPullDistance: CGFloat = 0 // 마지막 오버스크롤 거리
    private let refreshHeight: CGFloat = 80
    private let recentButton = UIButton(type: .system)
    
    // 1st 헤더에 들어가는 버튼
    private let thirdHeaderToggleButton = UIButton(type: .system)
    
    // 2nd 헤더 높이 제어용 제약
    private var secondHeaderHeightConstraint: NSLayoutConstraint!
    private var isSecondHeaderExpanded = true // 펼쳐짐 여부 상태
    
    // 3rd 헤더 높이 제어용 제약
    private var thirdHeaderHeightConstraint: NSLayoutConstraint!
    private var isThirdHeaderVisible = false
    
    // 스크롤 방향 판단용
    private var lastContentOffsetY: CGFloat = 0
    
    // 이번 제스쳐가 "최상단에서 시작된 풀투리프레쉬 시도인지" 여부
    private var isPullingFromTop = false
    
    // 하단 퀵 버튼 바
    private let quickButtonContainerView = UIView()
    private let quickButtonsStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        setupFirstHeaderView()
        setupSecondHeaderView()
        setupThirdHeaderView()
        setupRecentButton()
        setupTableView()
        setupQuickButtonsView()
    }
    
    private func setupLayout() {
        view.addSubview(firstHeaderView)
        view.addSubview(secondHeaderView)
        view.addSubview(thirdHeaderView)
        view.addSubview(tableView)
        firstHeaderView.translatesAutoresizingMaskIntoConstraints = false
        secondHeaderView.translatesAutoresizingMaskIntoConstraints = false
        thirdHeaderView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 1st 헤더는 safeArea 기준으로 고정
            firstHeaderView.topAnchor.constraint(equalTo: view.topAnchor),
            firstHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            firstHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // bottom을 safeArea 위에서 80 아래로 잡기 -> status bar + 80
            firstHeaderView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 80
            ),
            
            // 2nd 헤더: 높이 제약은 프로퍼티에 따로 저장
            secondHeaderView.topAnchor.constraint(equalTo: firstHeaderView.bottomAnchor),
            secondHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            secondHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // 3rd 헤더
            thirdHeaderView.topAnchor.constraint(equalTo: secondHeaderView.bottomAnchor),
            thirdHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            thirdHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            thirdHeaderView.heightAnchor.constraint(equalToConstant: 50),
            
            // table은 가장 아래에 위치
            tableView.topAnchor.constraint(equalTo: thirdHeaderView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 2nd 헤더 높이 제약을 변수로 잡아서 나중에 변경
        secondHeaderHeightConstraint = secondHeaderView.heightAnchor.constraint(equalToConstant: 100)
        secondHeaderHeightConstraint.isActive = true
        
        // 3rd 헤더 높이 제약 (기본: 0 -> 숨김)
        thirdHeaderHeightConstraint = thirdHeaderView.heightAnchor.constraint(equalToConstant: 0)
        thirdHeaderHeightConstraint.isActive = true
    }
    
    private func setupFirstHeaderView() {
        firstHeaderView.backgroundColor = .systemBlue
        
        let contentView = UIView()
        contentView.backgroundColor = .clear
        firstHeaderView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // firstHeaderView의 아래쪽 80pt만 사용
            contentView.leadingAnchor.constraint(equalTo: firstHeaderView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: firstHeaderView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: firstHeaderView.bottomAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        // 왼쪽 타이틀 레이블
        let titleLabel = UILabel()
        titleLabel.text = "1st 헤더 영역"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 16)
        
        // 3nd 헤더 토글 버튼 설정
        thirdHeaderToggleButton.setTitle("3rd 헤더 보이기", for: .normal)
        thirdHeaderToggleButton.setTitleColor(UIColor.white, for: .normal)
        thirdHeaderToggleButton.titleLabel?.font = .systemFont(ofSize: 16)
        thirdHeaderToggleButton.addTarget(self, action: #selector(didTapToggleThirdHeader), for: .touchUpInside)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(thirdHeaderToggleButton)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        thirdHeaderToggleButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 타이틀 레이블
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            // 토글 버튼
            thirdHeaderToggleButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thirdHeaderToggleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupSecondHeaderView() {
        secondHeaderView.backgroundColor = .clear
        secondHeaderView.clipsToBounds = true
        
        // 실제 컨텐츠를 담을 컨테이너
        let contentView = UIView()
        contentView.backgroundColor = .systemOrange
        
        secondHeaderView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: secondHeaderView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: secondHeaderView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: secondHeaderView.bottomAnchor),
            // 컨텐츠는 항상 100 높이 유지 (여기서 디자인에 맞게 조절 가능)
            contentView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // 그 안에 레이블 추가
        let titleLabel = UILabel()
        titleLabel.text = "2nd 헤더 영역"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 16)
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupThirdHeaderView() {
        thirdHeaderView.backgroundColor = .clear
        thirdHeaderView.clipsToBounds = true
        
        // 실제 컨텐츠를 담을 컨테이너
        let contentView = UIView()
        contentView.backgroundColor = .systemCyan
        
        thirdHeaderView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: thirdHeaderView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: thirdHeaderView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: thirdHeaderView.trailingAnchor),
            // 컨텐츠는 항상 50 높이 유지
            contentView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupRecentButton() {
        recentButton.backgroundColor = .systemGray
        recentButton.setTitle("최근 활동으로 이동", for: .normal)
        recentButton.setTitleColor(.white, for: .normal)
        recentButton.titleLabel?.font = .systemFont(ofSize: 16)
        recentButton.alpha = 0 // 처음에는 숨김
        recentButton.addTarget(self, action: #selector(didTapToggleThirdHeader), for: .touchUpInside)
        
        view.addSubview(recentButton)
        recentButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            recentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recentButton.topAnchor.constraint(equalTo: secondHeaderView.bottomAnchor, constant: 10),
            recentButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    // MARK: 2nd 헤더 토글 메서드 (스크롤용)
    private func expandSecondHeader(animated: Bool = true) {
        guard !isSecondHeaderExpanded else { return }
        isSecondHeaderExpanded = true
        secondHeaderHeightConstraint.constant = 100
        
        let animations = {
            self.view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.curveEaseInOut],
                           animations: animations,
                           completion: nil)
        } else {
            animations()
        }
    }
    
    private func collapseSecondHeader(animated: Bool = true) {
        guard isSecondHeaderExpanded else { return }
        isSecondHeaderExpanded = false
        secondHeaderHeightConstraint.constant = 0
        
        let animations = {
            self.view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.curveEaseInOut],
                           animations: animations,
                           completion: nil)
        } else {
            animations()
        }
    }
    
    // MARK: 3rd 헤더 토글 메서드 (버튼용)
    @objc private func didTapToggleThirdHeader() {
        isThirdHeaderVisible.toggle()
        
        thirdHeaderHeightConstraint.constant = isThirdHeaderVisible ? 50 : 0
        
        let title = isThirdHeaderVisible ? "3rd 헤더 숨기기" : "3rd 헤더 보이기"
        thirdHeaderToggleButton.setTitle(title, for: .normal)
        
        // Fade 준비
        if isThirdHeaderVisible {
            recentButton.alpha = 0
            view.bringSubviewToFront(recentButton)
        }
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
                // 3rd 헤더 height 애니메이션
                self.view.layoutIfNeeded()
                // recentButton fade
                self.recentButton.alpha = self.isThirdHeaderVisible ? 1 : 0
            }
        )
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderView.reuseIdentifier)
        tableView.separatorStyle = .none
        
        // iOS 15+에서 섹션 헤더 위쪽 여백 제거
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        // refreshView 기본 설정
        refreshView.backgroundColor = .systemGreen
        refreshView.frame = .zero
        tableView.addSubview(refreshView)
        
        // refreshLable 설정
        refreshLabel.text = "Pull to refresh"
        refreshLabel.textColor = .white
        refreshLabel.font = .systemFont(ofSize: 14, weight: .medium)
        refreshLabel.textAlignment = .center
        
        refreshView.addSubview(refreshLabel)
        refreshLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 로딩 스피너 설정
        loadingIndicator.hidesWhenStopped = true
        refreshView.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            refreshLabel.centerXAnchor.constraint(equalTo: refreshView.centerXAnchor),
            refreshLabel.centerYAnchor.constraint(equalTo: refreshView.centerYAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: refreshView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: refreshView.centerYAnchor)
        ])
    }
    
    private func setupQuickButtonsView() {
        quickButtonContainerView.backgroundColor = .secondarySystemBackground
        quickButtonContainerView.layer.cornerRadius = 16
        quickButtonContainerView.layer.masksToBounds = true
        
        view.addSubview(quickButtonContainerView)
        quickButtonContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            quickButtonContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            quickButtonContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            // ListVC.view의 bottom == 탭바 top이라서 여기 붙이면 "탭바 top에 위치"
            quickButtonContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            quickButtonContainerView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // 스택뷰
        quickButtonsStackView.axis = .horizontal
        quickButtonsStackView.alignment = .fill
        quickButtonsStackView.distribution = .fillEqually
        quickButtonsStackView.spacing = 8
        
        quickButtonContainerView.addSubview(quickButtonsStackView)
        quickButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            quickButtonsStackView.topAnchor.constraint(equalTo: quickButtonContainerView.topAnchor, constant: 8),
            quickButtonsStackView.leadingAnchor.constraint(equalTo: quickButtonContainerView.leadingAnchor, constant: 12),
            quickButtonsStackView.trailingAnchor.constraint(equalTo: quickButtonContainerView.trailingAnchor, constant: -12),
            quickButtonsStackView.bottomAnchor.constraint(equalTo: quickButtonContainerView.bottomAnchor, constant: -8)
        ])
        
        // 버튼들 추가
        let titles = ["오늘", "어제", "최근 활동"]
        for title in titles {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            button.addTarget(self, action: #selector(didTapQuickButton(_:)), for: .touchUpInside)
            quickButtonsStackView.addArrangedSubview(button)
        }
        
        // z-order 상 맨 위로 올리기 (tableView/헤더들 위)
        view.bringSubviewToFront(quickButtonContainerView)
        
        // 버튼에 가리지 않게 tableView 인셋 살짝 올려주기
        let bottom: CGFloat = 50 + 16
        tableView.contentInset.bottom += bottom
        tableView.scrollIndicatorInsets.bottom += bottom
    }
    
    @objc private func didTapQuickButton(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        
        switch title {
        case "오늘":
            print("오늘로 이동")
        case "어제":
            print("어제로 이동")
        case "최근 활동":
            print("최근 활동으로 이동")
        default:
            break
        }
    }
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    
    // 섹션 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        items.count
    }
    
    // 각 섹션의 셀 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items[section].count
    }
    
    // 셀 렌더링
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = items[indexPath.section][indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    // 섹션 헤더 뷰
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: SectionHeaderView.reuseIdentifier
        ) as? SectionHeaderView else {
            return nil
        }
        // 섹션별 타이틀 설정
        header.configure(text: "섹션 \(section)")
        return header
    }
    
    // 섹션 헤더 높이
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    // MARK: 스크롤 방향에 따라 2nd 헤더 접기/펼치기
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastContentOffsetY = scrollView.contentOffset.y
        
        let minOffsetY: CGFloat = -scrollView.adjustedContentInset.top
        // 약간의 오차 허용
        isPullingFromTop = scrollView.contentOffset.y <= minOffsetY + 0.1
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        // 컨텐츠 실제 스크롤 가능한 최대/최소 위치 계산
        let minOffsetY: CGFloat = -scrollView.adjustedContentInset.top
        let maxOffsetY: CGFloat = scrollView.contentSize.height - scrollView.bounds.height + scrollView.adjustedContentInset.bottom
        
        // refresh 중일 때는 위치/높이만 고정해 주고 나머지 로직은 건너뛴다
        if isRefreshing {
            refreshView.frame = CGRect(
                x: 0,
                y: y,
                width: tableView.bounds.width,
                height: refreshHeight
            )
            return
        }
        
        // 최상단에서 당기는 영역 처리 (refreshView용)
        if isPullingFromTop && y < minOffsetY {
            let overscroll = minOffsetY - y // 양수
            let height = overscroll // 당긴 만큼 전부 사용
            
            lastPullDistance = height // 마지막 당긴 거리 기록
            
            // refreshView가 당겨진 구간을 꽉 채우도록 배치
            refreshView.frame = CGRect(
                x: 0,
                y: minOffsetY - height, // 당긴 시작점부터
                width: tableView.bounds.width,
                height: height // minOffsetY까지 딱 채움
            )
            
            // 당긴 높이에 따라 메시지 변경
            if height < 100 {
                refreshLabel.text = "Pull to refresh"
            } else {
                refreshLabel.text = "Release to refresh"
            }
            
            // 오버스크롤 동안엔 2nd 헤더는 항상 펼쳐진 상태 유지
            expandSecondHeader(animated: true)
            
            // 2nd 헤더 토글 로직은 오버스크롤 중에는 건드리지 않음
            lastContentOffsetY = y
            return
        } else {
            // 오버스크롤 종료
            lastPullDistance = 0 // 초기화
            // 오버스크롤 영역에서 벗어나면 refreshView는 다시 접기
            if refreshView.frame.height != 0 {
                refreshView.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: tableView.bounds.width,
                    height: 0
                )
            }
        }
        
        // 최상단에서부터 200pt 아래까지는 2nd 헤더 항상 펼치기 (접히지 않도록)
        let stickyRange: CGFloat = 200 // 원하는 값으로 조절
        if y <= minOffsetY + stickyRange {
            expandSecondHeader(animated: false) // 매 프레임 호출되니 애니메이션은 끔
            lastContentOffsetY = y
            return
        }
        
        // 최상단/최하단 바운스 영역에서는 헤더 토글하지 않도록 그냥 리턴
        if y < minOffsetY {
            lastContentOffsetY = y
            return
        }
        if y > maxOffsetY {
            lastContentOffsetY = y
            return
        }
        
        let delta = y - lastContentOffsetY
        
        // 너무 미세한 움직임은 무시 (떨림 방지)
        guard abs(delta) > 3 else { return }
        
        if delta > 0 {
            // 위로 스크롤(아래로 내려가는 방향) -> 헤더 접기
            collapseSecondHeader()
        } else {
            // 아래로 스크롤(위로 올리는 방향) -> 헤더 펼치기
            expandSecondHeader()
        }
        
        lastContentOffsetY = y
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // pull-to-refresh 발동 조건:
        // 1. 최상단에서 시작했고(isPullingFromTop)
        // 2. 아직 refresh 중이 아니며(isRefreshing = false)
        // 3. 당긴 높이가 100 이상었을 때
        if isPullingFromTop && !isRefreshing && lastPullDistance >= 100 {
            beginRefresh()
        }
        
        if !decelerate {
            isPullingFromTop = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isPullingFromTop = false
    }
    
    private func beginRefresh() {
        isRefreshing = true
        
        // 텍스트 숨기고 스피너 보여주기
        refreshLabel.isHidden = true
        loadingIndicator.startAnimating()
        
        // 현재 Inset 기준으로 refreshHeight만큼 top inset 추가
        let currentInset = tableView.contentInset
        let newTopInset = currentInset.top + refreshHeight
        
        UIView.animate(withDuration: 0.25) {
            // 리스트 내용을 아래로 밀기
            self.tableView.contentInset.top = newTopInset
            // 최상단 위치로 맞춰놓기
            self.tableView.contentOffset.y = -newTopInset
        }
        
        // 1초 후 refresh 종료
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.endRefresh()
        }
    }
    
    private func endRefresh() {
        isRefreshing = false
        
        loadingIndicator.stopAnimating()
        
        // 현재 inset에서 refreshHeight만큼 빼기
        let currentInset = tableView.contentInset
        let newTopInset = max(0, currentInset.top - refreshHeight)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.tableView.contentInset.top = newTopInset
            // 초록 바는 위로 사라지게
            self.refreshView.frame = CGRect(
                x: 0,
                y: 0,
                width: self.tableView.bounds.width,
                height: 0
            )
        }, completion: { _ in
            self.refreshLabel.isHidden = false
            self.refreshLabel.text = "Pull to refresh"
        })
    }
}

final class SectionHeaderView: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = "SectionHeaderView"
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()
    
    // 외부에서 텍스트 세팅
    func configure(text: String) {
        titleLabel.text = text
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        // 배경색
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
