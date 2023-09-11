import UIKit

class ViewController: UIViewController {
    
    let videoManager = ThreeMealVideo.shared
    let saveManager = SaveDatas.shared
    var searchResult: [VideoData] = []
    var categoryResult: [VideoData] = []
    var lastPressedButton: UIButton?
    
    var isEditMode: Bool {
        let searchController = navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let isSearchBarHasText = searchController?.searchBar.text?.isEmpty == false
        return isActive && isSearchBarHasText
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var videoTable: UITableView!
    let headerView = VideoTableHeaderView(frame: CGRect(x: 0, y: 0, width: 0, height: 60))  // 44는 원하는 높이입니다.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupIndicator()
        setupNaviBar()
        setupData()
        setupTableView()
    }
    
    func setupIndicator() {
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    func setupNaviBar() {
        title = "소주 지도"
        self.navigationController?.tabBarItem.title = ""
        self.navigationController?.tabBarItem.image = UIImage(systemName: "play.rectangle")
        // (네비게이션바 설정관련) iOS버전 업데이트 되면서 바뀐 설정⭐️⭐️⭐️
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()  // 불투명으로
        appearance.backgroundColor = .white // bartintcolor가 15버전부터 appearance로 설정하게끔 바뀜
        appearance.largeTitleTextAttributes = [.foregroundColor: Mycolor.title ]
        appearance.titleTextAttributes = [.foregroundColor: Mycolor.title ]
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.tintColor = Mycolor.title
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.compactAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "검색"
//        searchController.searchBar.searchTextField.backgroundColor = Mycolor.searchBar
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setupData() {
        saveManager.readMemoData()
        if saveManager.saveMemoList.isEmpty {
            self.activityIndicator.startAnimating()
            videoManager.fetchChannelData { result in
                guard let result = result else { return }
                self.videoManager.fetchVideoData(playlistID: result) { [weak self] videoResult in
                    self?.saveManager.saveMemoList = videoResult
                    self?.saveManager.saveMemoData()
                    DispatchQueue.main.async { [weak self] in
                        self?.videoTable.reloadData()
                        self?.newDateAction((self?.headerView.KindOfNewDate)!)
                        self?.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    func setupTableView() {
        videoTable.dataSource = self
        videoTable.delegate = self
        videoTable.rowHeight = 110
        videoTable.separatorStyle = .none
        headerView.KindOfPopular.addTarget(self, action: #selector(popularAction), for: .touchUpInside)
        headerView.KindOfOldDate.addTarget(self, action: #selector(oldDateAction), for: .touchUpInside)
        headerView.KindOfNewDate.addTarget(self, action: #selector(newDateAction), for: .touchUpInside)
        headerView.KindOfWish.addTarget(self, action: #selector(wishAction), for: .touchUpInside)
        videoTable.tableHeaderView = headerView
        newDateAction(headerView.KindOfNewDate)
    }
    
    @objc func popularAction(_ sender: UIButton) {
        categoryResult = self.saveManager.saveMemoList.sorted(by: { first, second in
            guard let firstCount = Int(first.viewCount ?? "0"),
                  let secondCount = Int(second.viewCount ?? "0") else { return false }
            return firstCount > secondCount
        })
        self.lastPressedButton = sender
        self.videoTable.reloadData()
    }
    
    @objc func oldDateAction(_ sender: UIButton) {
        categoryResult = self.saveManager.saveMemoList.sorted(by: { first, second in
            guard let firstdate = first.uploadDate,
                  let seconddate = second.uploadDate else { return false }
            return firstdate < seconddate
        })
        self.lastPressedButton = sender
        self.videoTable.reloadData()
    }
    
    @objc func newDateAction(_ sender: UIButton) {
        print("test")
        categoryResult = self.saveManager.saveMemoList.sorted(by: { first, second in
            guard let firstdate = first.uploadDate,
                  let seconddate = second.uploadDate else { return false }
            return firstdate > seconddate
        })
        self.lastPressedButton = sender
        self.videoTable.reloadData()
    }
    
    @objc func wishAction(_ sender: UIButton) {
        let wishResult = self.saveManager.saveMemoList.filter({ $0.wish })
        categoryResult = wishResult.sorted(by: { first, second in
            guard let firstDate = first.wishDate,
                  let secondDate = second.wishDate else { return false }
            return firstDate > secondDate
        })
        self.lastPressedButton = sender
        self.videoTable.reloadData()
    }
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isEditMode ? searchResult.count : categoryResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = videoTable.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoTableViewCell
        
        let video = isEditMode ? searchResult[indexPath.row] : categoryResult[indexPath.row]
        
        cell.video = video
        cell.saveButtonPressed = { [weak self] (saveCell, pressed) in
            
            guard let self = self else { return }
            if !pressed {
                saveCell.video?.wish = true
                saveCell.video?.wishDate = Date()
                self.saveManager.saveMemoData()
                saveCell.setButtonStatus()
            } else {
                saveCell.video?.wish = false
                saveCell.video?.wishDate = nil
                print("유저데이터 : \(self.saveManager.saveMemoList[indexPath.row].wish)")
                self.saveManager.saveMemoData()
                saveCell.setButtonStatus()
                guard let videoIndex = self.categoryResult.firstIndex(of: video) else { return }
                if self.lastPressedButton == self.headerView.KindOfWish {
                    self.categoryResult.remove(at: videoIndex)
                    self.videoTable.reloadData()
                }
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "PlaceDetailViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PlaceDetailViewController") as! PlaceDetailViewController
        vc.videoData = isEditMode ? searchResult[indexPath.row] : categoryResult[indexPath.row]
        
        present(vc, animated: true)
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let resultText = searchController.searchBar.text else { return }
        searchResult = saveManager.saveMemoList.filter({ result in
            
            if let title = result.title, title.contains(resultText) {
                return true
            }
            
            for info in result.videoInfo {
                if let info = info, info.contains(resultText) {
                    return true
                }
            }
            return false
        })
        videoTable.reloadData()
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}
