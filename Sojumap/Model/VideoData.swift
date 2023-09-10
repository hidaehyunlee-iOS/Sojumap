import Foundation

class VideoData: Codable, Equatable {
    static var number = 0
    //
    var videoId: String?
    var title: String?
    var thumbnail: String?
    var uploadDate: String?
    var description: String?
    var viewCount: String?
    var wish: Bool = false
    
    static func == (lhs: VideoData, rhs: VideoData) -> Bool {
          return lhs.videoId == rhs.videoId &&
                 lhs.title == rhs.title &&
                 lhs.thumbnail == rhs.thumbnail &&
                 lhs.uploadDate == rhs.uploadDate &&
                 lhs.description == rhs.description &&
                 lhs.viewCount == rhs.viewCount &&
                 lhs.wish == rhs.wish
      }
    
    var videoInfo: [String?] {
        guard let description = description else { return [] }
        
        let pattern = "\\[식당정보\\](.*?)\\n\\n"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
            let matches = regex.matches(in: description, options: [], range: NSRange(location: 0, length: description.utf16.count))
            
            if let match = matches.first {
                if let range = Range(match.range(at: 1), in: description) {
                    var restaurantInfoBlock = String(description[range])
                    restaurantInfoBlock = restaurantInfoBlock.replacingOccurrences(of: "1\\. ", with: "", options: .regularExpression)
                    let restaurantInfoLines = restaurantInfoBlock.components(separatedBy: "\n").filter { !$0.isEmpty }
                    return restaurantInfoLines
                }
            }
        } catch {
            print("정규 표현식 오류: \(error.localizedDescription)")
        }
        return []
    }
    
    var hashtags: [String?] {
        guard let description = description else { return [] }
        
        let pattern = "#\\w+" // 해시태그를 찾는 정규 표현식 패턴
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: description, options: [], range: NSRange(location: 0, length: description.utf16.count))
            
            let hashtags = matches.map { match in
                if let range = Range(match.range, in: description) {
                    return String(description[range])
                }
                return ""
            }
            return hashtags
        } catch {
            print("해시태그 추출 오류: \(error.localizedDescription)")
        }
        return []
    }
    
    var dateAndCount: String? {
        guard let date = releaseDateString,
              let count = releaseViewCount else { return "" }
        return "\(count) ･ \(date)"
    }
    
    var releaseDateString: String? {
        // 서버에서 주는 형태 (ISO규약에 따른 문자열 형태)
        guard let isoDate = ISO8601DateFormatter().date(from: uploadDate ?? "") else {
            return ""
        }
        let myFormatter = DateFormatter()
        myFormatter.dateFormat = "yy.MM.dd"
        let dateString = myFormatter.string(from: isoDate)
        return "\(dateString)"
    }
    
    var releaseViewCount: String? {
        guard let viewCount = viewCount,
             let viewDouble = Double(viewCount) else { return ""}
        
        switch viewDouble {
        case 10000... :
            let result = releaseCount(count: viewDouble, unit: 10000)
            return "조회수 \(result)만회"
        case 1000... :
            let result = releaseCount(count: viewDouble, unit: 1000)
            return "조회수 \(result)천회"
        default:
            return "조회수 \(viewDouble)회"
        }
    }
    
    func releaseCount(count: Double, unit: Double) -> Double {
        let oneStep = count / unit
        let twoStep = round(oneStep * 10) / 10
        return twoStep
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
