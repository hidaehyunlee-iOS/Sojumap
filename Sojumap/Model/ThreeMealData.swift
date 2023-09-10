import GoogleAPIClientForREST

class ThreeMealVideo {
    
    static let shared = ThreeMealVideo()
    
    private var youtubeService = GTLRYouTubeService()
    
    private init() {}
    
    func fetchChannelData(completion: @escaping (String?) -> Void) {
        // 채널 정보를 가져오는 요청 생성 및 실행
        youtubeService.apiKey = Google_KEY
        
        let channelQuery = GTLRYouTubeQuery_ChannelsList.query(withPart: ["contentDetails"])
        channelQuery.identifier = ["UC-x55HF1-IilhxZOzwJm7JA"]
        
        youtubeService.executeQuery(channelQuery) { (ticket, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // 채널 정보를 성공적으로 가져왔을 때
            // 업로드 플레이리스트 ID를 추출하여 completion handler로 전달
            guard let channelListResponse = response as? GTLRYouTube_ChannelListResponse,
                  let channel = channelListResponse.items?.first,
                  let contentDetails = channel.contentDetails,
                  let relatedPlaylists = contentDetails.relatedPlaylists,
                  let uploadsPlaylistID = relatedPlaylists.uploads else {
                completion(nil)
                return
            }
            
            completion(uploadsPlaylistID)
        }
    }
    
    func fetchVideoData(playlistID: String, completion: @escaping ([VideoData]) -> Void) {
        print("test")
        var videoArray: [VideoData] = []
        
        func fetchPage(pageToken: String?) {
            // 채널의 동영상 목록을 가져오는 요청 생성 및 실행
            let playlistItemsQuery = GTLRYouTubeQuery_PlaylistItemsList.query(withPart: ["snippet"])
            playlistItemsQuery.playlistId = playlistID
            playlistItemsQuery.maxResults = 30 // 가져올 동영상 개수를 설정
            
            if let pageToken = pageToken {
                playlistItemsQuery.pageToken = pageToken
            }
            
            youtubeService.executeQuery(playlistItemsQuery) { (ticket, response, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                // 동영상 정보를 성공적으로 가져왔을 때
                // 각 동영상의 정보를 추출하여 videoArray에 추가
                guard let playlistItemsListResponse = response as? GTLRYouTube_PlaylistItemListResponse else {
                    completion([])
                    return
                }
                
                let group = DispatchGroup() // 동시에 여러 비동기 작업을 기다리기 위한 DispatchGroup 생성
                
                for playlistItem in playlistItemsListResponse.items ?? [] {
                    guard let videoId = playlistItem.snippet?.resourceId?.videoId,
                          let title = playlistItem.snippet?.title,
                          let thumbnailUrl = playlistItem.snippet?.thumbnails?.maxres?.url,
                          let uploadDate = playlistItem.snippet?.publishedAt,
                          let description = playlistItem.snippet?.description else {
                        continue
                    }
                    
                    group.enter() // DispatchGroup에 진입을 표시
                    
                    // 각 동영상의 조회수를 가져오는 함수 호출
                    self.fetchVideoViewCount(videoId: videoId) { viewCount in
                        // 조회수를 비동기 작업 내에서 받아서 처리
                        let threeMealVideo = VideoData(videoId: videoId, title: title, thumbnail: thumbnailUrl, uploadDate: uploadDate.stringValue, description: description, viewCount: viewCount)
                        videoArray.append(threeMealVideo)
                         
                        print("\(VideoData.number)번째 동영상")
                        print("Video ID: \(threeMealVideo.videoId)")
                        print("Title: \(threeMealVideo.title)")
                        print("Thumbnail URL: \(threeMealVideo.thumbnail)")
                        print("Upload Date: \(threeMealVideo.releaseDateString)")
                        print("Description: \(threeMealVideo.videoInfo)")
                        print("View Count: \(threeMealVideo.viewCount)")
                        print("\n")
                        
                        group.leave() // DispatchGroup에서 나옴
                    }
                }
                // 모든 조회수를 가져오는 비동기 작업이 완료될 때까지 기다립니다.
                group.notify(queue: .main) {
                    if let nextPageToken = playlistItemsListResponse.nextPageToken {
                        // 다음 페이지가 있으면 재귀적으로 호출하여 다음 페이지의 동영상 가져오기
                        fetchPage(pageToken: nextPageToken)
                    } else {
                        // 다음 페이지가 없으면 모든 동영상을 가져온 것이므로 완료 처리
                        completion(videoArray)
                    }
                }
            }
        }
        fetchPage(pageToken: nil)
    }
    
    func fetchVideoViewCount(videoId: String, completion: @escaping (String) -> Void) {
        // 각 동영상의 조회수를 가져오는 요청 생성
        let videoQuery = GTLRYouTubeQuery_VideosList.query(withPart: ["statistics"])
        videoQuery.identifier = [videoId]
        
        // 조회수를 가져오는 요청 실행 (비동기적으로)
        youtubeService.executeQuery(videoQuery) { (_, videoResponse, videoError) in
            if let videoError = videoError {
                print("Video Error: \(videoError.localizedDescription)")
                completion("") // 조회수 가져오기 실패 시 빈 문자열 반환
                return
            }
            
            guard let videoListResponse = videoResponse as? GTLRYouTube_VideoListResponse,
                  let video = videoListResponse.items?.first,
                  let viewCount = video.statistics?.viewCount else {
                completion("") // 조회수 가져오기 실패 시 빈 문자열 반환
                return
            }
            
            completion(viewCount.stringValue) // 조회수를 비동기 작업 내에서 반환
        }
    }
}
