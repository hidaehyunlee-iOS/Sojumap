import Foundation

struct VideoData: Codable {
    static var number = 0
    
    var videoId: String?
    var title: String?
    var thumbnail: String?
    var uploadDate: String?
    var description: String?
    var viewCount: String?
    
    var videoInfo: [String?] {
        guard let description = description else { return [] }
        
        let pattern = "\\[식당정보\\](.*?)\\n\\n"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
            let matches = regex.matches(in: description, options: [], range: NSRange(location: 0, length: description.utf16.count))
            
            if let match = matches.first {
                if let range = Range(match.range(at: 1), in: description) {
                    let restaurantInfoBlock = String(description[range])
                    let restaurantInfoLines = restaurantInfoBlock.components(separatedBy: "\n").filter { !$0.isEmpty }
                    return restaurantInfoLines
                }
            }
        } catch {
            print("정규 표현식 오류: \(error.localizedDescription)")
        }
        return []
    }
    
    var releaseDateString: String? {
        // 서버에서 주는 형태 (ISO규약에 따른 문자열 형태)
        guard let isoDate = ISO8601DateFormatter().date(from: uploadDate ?? "") else {
            return ""
        }
        let myFormatter = DateFormatter()
        myFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = myFormatter.string(from: isoDate)
        return dateString
    }

    init(videoId: String?, title: String?, thumbnail: String?, uploadDate: String?, description: String?, viewCount: String?) {
        self.videoId = videoId
        self.uploadDate = uploadDate
        self.title = title
        self.thumbnail = thumbnail
        self.description = description
        self.viewCount = viewCount

        VideoData.number += 1
    }
}
