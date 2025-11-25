import UIKit

final class ListViewController: UIViewController {
    private let headerBoxView = UIView()
    private let tableView = UITableView()
    private let items: [[String]] = (0..<10).map { section in
        (0..<10).map { row in
            "섹션 \(section) - 셀 \(row)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        setupHeaderBox()
        setupTableView()
    }
    
    private func setupLayout() {
        view.addSubview(headerBoxView)
        view.addSubview(tableView)
        headerBoxView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // 상단 박스는 safeArea 기준으로 고정
            headerBoxView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerBoxView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerBoxView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerBoxView.heightAnchor.constraint(equalToConstant: 80),
            // tableView는 박스 아래에 위치
            tableView.topAnchor.constraint(equalTo: headerBoxView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupHeaderBox() {
        headerBoxView.backgroundColor = .systemBlue
        // 안에 label 같은 것 넣어도 됨 (예시)
        let titleLabel = UILabel()
        titleLabel.text = "상단 박스 영역"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 18)
        headerBoxView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: headerBoxView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: headerBoxView.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderView.reuseIdentifier)
        // iOS 15+ 에서 섹션 헤더 위쪽 여백 제거
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
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
