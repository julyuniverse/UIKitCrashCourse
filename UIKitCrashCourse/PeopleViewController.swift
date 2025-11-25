import UIKit
import SafariServices

class PeopleViewController: UIViewController {
    private let vm = PeopleViewModel()
    private lazy var cv: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: UIScreen.main.bounds.width, height: 130)
        let vw = UICollectionView(frame: .zero, collectionViewLayout: layout)
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.register(PersonCollectionViewCell.self, forCellWithReuseIdentifier: "PersonCollectionViewCell")
        vw.dataSource = self
        return vw
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Ya boys in mem!")
        setup()
        vm.deletegate = self
        vm.getUsers()
    }
}

extension PeopleViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.people.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = vm.people[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonCollectionViewCell", for: indexPath) as! PersonCollectionViewCell
        cell.item = item
        cell.delegate = self
        return cell
    }
}

extension PeopleViewController: PeopleViewModelDeletegate {
    
    func didFinish() {
        cv.reloadData()
    }
    
    func didFail(error: any Error) {
        print(error)
    }
}

extension PeopleViewController: PersonCollectionViewCellDelegate {
    
    func didTapSubscribe() {
        let url = URL(string: "https://julyuniverse.com")!
        let vc = SFSafariViewController(url: url)
        vc.modalPresentationStyle = .formSheet
        self.present(vc, animated: true)
    }
}

private extension PeopleViewController {
    
    func setup() {
        view.backgroundColor = .white
        view.addSubview(cv)
        NSLayoutConstraint.activate([
            cv.topAnchor.constraint(equalTo: view.topAnchor),
            cv.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cv.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
