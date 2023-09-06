import GoogleAPIClientForREST

enum networkingError: Error {
    case networkError
}

class YouTubeChannelViewControllers {
    
    static let shared = YouTubeChannelViewControllers()
    
    private var youtubeService = GTLRYouTubeService()
    
    typealias NetworkCompletion = (Result<[VideoData],networkingError>) -> Void
    
    private init() {}
    
    func fetchChannelData(completion: @escaping NetworkCompletion) {
        youtubeService.apiKey = "AIzaSyD7WHU1xDJm-m1FHb8mInPfKDOdcPlYgcY"
        
        // 채널 정보를 가져오는 요청 생성 및 실행
        let channelQuery = GTLRYouTubeQuery_ChannelsList.query(withPart: ["contentDetails"])
        channelQuery.identifier = ["UC-x55HF1-IilhxZOzwJm7JA"]
        
        youtubeService.executeQuery(channelQuery) { (ticket, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(.failure(.networkError))
                return
            }
            
            // 채널 정보를 성공적으로 가져왔을 때
            // 업로드 플레이리스트 ID를 추출하여 completion handler로 전달
            guard let channelListResponse = response as? GTLRYouTube_ChannelListResponse,
                  let channel = channelListResponse.items?.first,
                  let contentDetails = channel.contentDetails,
                  let relatedPlaylists = contentDetails.relatedPlaylists,
                  let uploadsPlaylistID = relatedPlaylists.uploads else {
                completion(.failure(.networkError))
                return
            }
            
//            completion(uploadsPlaylistID)
            self.fetchVideoData(playlistID: uploadsPlaylistID) { result in
                completion(result)
            }
        }
    }
    
    func fetchVideoData(playlistID: String, completion: @escaping NetworkCompletion) {
        var videoArray: [VideoData] = []
        
        // 채널의 동영상 목록을 가져오는 요청 생성 및 실행
        let playlistItemsQuery = GTLRYouTubeQuery_PlaylistItemsList.query(withPart: ["snippet"])
        playlistItemsQuery.playlistId = playlistID
        playlistItemsQuery.maxResults = 1 // 가져올 동영상 개수를 설정
        
        youtubeService.executeQuery(playlistItemsQuery) { (ticket, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(.failure(.networkError))
                return
            }
            
            // 동영상 정보를 성공적으로 가져왔을 때
            // 각 동영상의 정보를 추출하여 videoArray에 추가
            guard let playlistItemsListResponse = response as? GTLRYouTube_PlaylistItemListResponse else {
                completion(.failure(.networkError))
                return
            }
            
            for playlistItem in playlistItemsListResponse.items ?? [] {
                guard let videoId = playlistItem.snippet?.resourceId?.videoId,
                      let title = playlistItem.snippet?.title,
                      let thumbnailUrl = playlistItem.snippet?.thumbnails?.defaultProperty?.url,
                      let uploadDate = playlistItem.snippet?.publishedAt,
                      let description = playlistItem.snippet?.description else {
                    continue
                }
                
                let threeMealVideo = VideoData(videoId: videoId, title: title, thumbnail: thumbnailUrl, uploadDate: uploadDate.stringValue, description: description, viewCount: "")
                videoArray.append(threeMealVideo)
            }
            
            completion(.success(videoArray))
        }
    }
}

// 각 동영상의 정보 출력
//print("\(VideoData.number)번째 동영상")
//print("Video ID: \(threeMealVideo.videoId)")
//print("Title: \(threeMealVideo.title)")
//print("Thumbnail URL: \(threeMealVideo.thumbnail)")
//print("Upload Date: \(threeMealVideo.releaseDateString)")
//print("Description: \(threeMealVideo.videoInfo)")
//print("View Count: \(threeMealVideo.viewCount)")
//print("\n")
