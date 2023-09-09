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
        title = "Soju Map"
        
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
    }
    
    func setupTableView() {
        videoTable.dataSource = self
        videoTable.delegate = self
        videoTable.rowHeight = 110
    }
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isEditMode ? searchResult.count : saveManager.saveMemoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = videoTable.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoTableViewCell
        
        let video = isEditMode ? searchResult[indexPath.row] : saveManager.saveMemoList[indexPath.row]

        cell.imageUrl = video.thumbnail
        cell.videoTitle.text = video.title
        cell.videoInfo.text = video.dateAndCount
        cell.selectionStyle = .none
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "PlaceDetailViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PlaceDetailViewController") as! PlaceDetailViewController
        vc.videoData = isEditMode ? searchResult[indexPath.row] : saveManager.saveMemoList[indexPath.row]
        
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
