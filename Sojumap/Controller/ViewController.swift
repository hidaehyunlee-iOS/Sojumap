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
    @IBOutlet weak var videoTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupTableView()
    }
    
    func setupData() {
        saveManager.readMemoData()
        if saveManager.saveMemoList.isEmpty {
            videoManager.fetchChannelData { result in
                guard let result = result else { return }
                self.videoManager.fetchVideoData(playlistID: result) { [weak self] videoResult in
                    self?.saveManager.saveMemoList = videoResult
                    self?.saveManager.saveMemoData()
                }
            }
        }
    }
    
    func setupTableView() {
        videoTable.dataSource = self
        videoTable.delegate = self
        videoTable.rowHeight = 150
    }
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return saveManager.saveMemoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = videoTable.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoTableViewCell
        
        cell.imageUrl = saveManager.saveMemoList[indexPath.row].thumbnail
        cell.videoTitle.text = saveManager.saveMemoList[indexPath.row].title
        cell.videoInfo.text = saveManager.saveMemoList[indexPath.row].viewCount
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "PlaceDetailViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PlaceDetailViewController") as! PlaceDetailViewController
//        vc.videoData = saveManager.saveMemoList[indexPath.row]
        // 동영상 뷰컨트롤러에 비디오데이터 받을 변수 생성
        
        present(vc, animated: true)
    }
}
