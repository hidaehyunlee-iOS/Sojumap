import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let youtubeManager = ThreeMealVideo.shared
    
    let userData = VideoUserDatas.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userData.readMemoData()
        print("\(userData.saveMemoList.count)")
        tableView.dataSource = self
        tableView.rowHeight = 130
        setupData()
    }
    
    func setupData() {
        if userData.saveMemoList.isEmpty {
            youtubeManager.fetchChannelData { result in
                guard let result = result else { return }
                self.youtubeManager.fetchVideoData(playlistID: result) { videoResult in
                    self.userData.saveMemoList = videoResult
                    self.userData.saveMemoData()
                }
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    // 1) 테이블뷰에 몇개의 데이터를 표시할 것인지(셀이 몇개인지)를 뷰컨트롤러에게 물어봄
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userData.saveMemoList.count
    }
    
    // 2) 셀의 구성(셀에 표시하고자 하는 데이터 표시)을 뷰컨트롤러에게 물어봄
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(#function)
        
        // (힙에 올라간)재사용 가능한 셀을 꺼내서 사용하는 메서드 (애플이 미리 잘 만들어 놓음)
        // (사전에 셀을 등록하는 과정이 내부 메커니즘에 존재)
        let cell = tableView.dequeueReusableCell(withIdentifier: "YoutubeCell", for: indexPath) as! YoutubeCell
        
        cell.imageUrl = userData.saveMemoList[indexPath.row].thumbnail
        cell.title.text = userData.saveMemoList[indexPath.row].title
        cell.viewCountAndDate.text = userData.saveMemoList[indexPath.row].viewCount
        cell.selectionStyle = .none
        
        return cell
    }
}
