//
//  ViewController.swift
//  Sojumap
//
//  Created by daelee on 2023/09/04.
//

import UIKit

class ViewController: UIViewController {
    
    let videoManager = ThreeMealVideo.shared
    let saveManager = SaveDatas.shared
    var searchResult: [VideoData] = []
    var categoryResult: [VideoData] = []
    
    var isEditMode: Bool {
        let searchController = navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let isSearchBarHasText = searchController?.searchBar.text?.isEmpty == false
        return isActive && isSearchBarHasText
    }
    
    @IBOutlet weak var videoTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupTableView()
        setupNaviBar()
    }
    
    func setupNaviBar() {
        title = "Sojudd Map"
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
        searchController.searchBar.searchTextField.backgroundColor = Mycolor.searchBar
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setupData() {
        saveManager.readMemoData()
        if saveManager.saveMemoList.isEmpty {
            videoManager.fetchChannelData { result in
                guard let result = result else { return }
                self.videoManager.fetchVideoData(playlistID: result) { [weak self] videoResult in
                    self?.saveManager.saveMemoList = videoResult
                    self?.saveManager.saveMemoData()
                    DispatchQueue.main.async { [weak self] in
                        self?.videoTable.reloadData()
                    }
                }
            }
        }
        newDateAction()
    }
    
    func setupTableView() {
        videoTable.dataSource = self
        videoTable.delegate = self
        videoTable.rowHeight = 110
        videoTable.separatorStyle = .none
        let test = VideoTableHeaderView(frame: CGRect(x: 0, y: 0, width: 0, height: 30))  // 44는 원하는 높이입니다.
        test.KindOfPopular.addTarget(self, action: #selector(popularAction), for: .touchUpInside)
        test.KindOfOldDate.addTarget(self, action: #selector(oldDateAction), for: .touchUpInside)
        test.KindOfNewDate.addTarget(self, action: #selector(newDateAction), for: .touchUpInside)
        test.KindOfWish.addTarget(self, action: #selector(wishAction), for: .touchUpInside)
        videoTable.tableHeaderView = test
    }
    
    @objc func popularAction() {
        categoryResult = self.saveManager.saveMemoList.sorted(by: { first, second in
            guard let firstCount = Int(first.viewCount ?? "0"),
                 let secondCount = Int(second.viewCount ?? "0") else { return false }
            return firstCount > secondCount
        })
        self.videoTable.reloadData()
    }
    
    @objc func oldDateAction() {
        categoryResult = self.saveManager.saveMemoList.sorted(by: { first, second in
            guard let firstdate = first.uploadDate,
                 let seconddate = second.uploadDate else { return false }
            return firstdate < seconddate
        })
        self.videoTable.reloadData()
    }
    
    @objc func newDateAction() {
        categoryResult = self.saveManager.saveMemoList.sorted(by: { first, second in
            guard let firstdate = first.uploadDate,
                 let seconddate = second.uploadDate else { return false }
            return firstdate > seconddate
        })
        self.videoTable.reloadData()
    }
    
    @objc func wishAction() {
        categoryResult = self.saveManager.saveMemoList.filter({ $0.wish })
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
                self.saveManager.saveMemoData()
                saveCell.setButtonStatus()
            } else {
                saveCell.video?.wish = false
                print("유저데이터 : \(self.saveManager.saveMemoList[indexPath.row].wish)")
                self.saveManager.saveMemoData()
                saveCell.setButtonStatus()
                guard let videoIndex = self.categoryResult.firstIndex(of: video) else { return }
                self.categoryResult.remove(at: videoIndex)
                self.videoTable.reloadData()
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
