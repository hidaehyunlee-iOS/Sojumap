import Foundation

class VideoUserDatas {
    static let shared = VideoUserDatas()
    
    private let userdata = UserDefaults.standard
    
    var saveMemoList: [VideoData] = []
    
    private init() {}
    
    // MARK: - SETUP DATA
    
    func saveMemoData() {
        print("유저데이터에 저장")

        if let data = try? JSONEncoder().encode(saveMemoList) {
            userdata.set(data, forKey: "videoList")
        }
    }
    
    func readMemoData() {
        print("유저데이터에서 불러오기")
        if let data = userdata.data(forKey: "videoList") {
            if let readData = try? JSONDecoder().decode([VideoData].self, from: data) {
                saveMemoList = readData
            }
        }
    }
}
