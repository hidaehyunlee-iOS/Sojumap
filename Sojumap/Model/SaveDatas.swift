import Foundation

class SaveDatas {
    static let shared = SaveDatas()
    
    private let userdata = UserDefaults.standard
    
    var saveMemoList: [VideoData] = []
    var wishVideoList: [VideoData] = []
    
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
    
    func saveWishData() {
        if let data = try? JSONEncoder().encode(wishVideoList) {
            userdata.set(data, forKey: "wishList")
        }
    }
    
    func readWishData() {
        if let data = userdata.data(forKey: "wishList") {
            if let readData = try? JSONDecoder().decode([VideoData].self, from: data) {
                wishVideoList = readData
            }
        }
    }
    
    func deleteWishData(delete: VideoData) {
        let deleteIndex = self.wishVideoList.firstIndex(of: delete)
        guard let deleteInt = deleteIndex else { return }
        self.wishVideoList.remove(at: deleteInt)
    }
    
    func checkSaved() {
        saveMemoList.forEach { video in
            if wishVideoList.contains(where: {
                $0.title == video.title && $0.dateAndCount == video.dateAndCount }) {
                video.wish = true
            }
        }
    }
}
