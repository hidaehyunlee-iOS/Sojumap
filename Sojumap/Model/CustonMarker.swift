//
//  CustonMarker.swift
//  Sojumap
//
//  Created by daelee on 2023/09/07.
//

import Foundation
import NMapsMap

// 디테일 페이지에서 필요한 변수
// videoid, 썸네일, 제목, 조회수, 해시태그, 식당이름, 식당 주소, 식당url(네이버 링크)

class CustomMarker: NMFMarker {
    var videoId: String?
    var thumbnail: String?
    var videoTitle: String?
    var viewCnt: String?
    var placeName: String?
    var address: String?
    var placeUrl: String?
    var distanceKM: Double?
    var customUserInfo: [String: Any]? // 마커를 인덱스로 식별할 수 있도록 하는 속성 1, 2, 3 ... 순으로 진행
    
    init(position: NMGLatLng, videoId: String?, thumbnail: String?, videoTitle: String?, viewCnt: String?, placeName: String?, address: String?, placeUrl: String?, distanceKM: Double? = nil, customUserInfo: [String : Any]? = nil) {
        super.init()
        
        self.position = position
        self.videoId = videoId ?? "DefaultVideoID"
        self.thumbnail = thumbnail ?? "DefaultThumbnailURL"
        self.videoTitle = videoTitle ?? "DefaultVideoTitle"
        self.viewCnt = viewCnt ?? "DefaultViewCount"
        self.placeName = placeName ?? "DefaultPlaceName"
        self.address = address ?? "DefaultAddress"
        self.placeUrl = placeUrl ?? "DefaultPlaceURL"
        self.distanceKM = distanceKM
        self.customUserInfo = customUserInfo
    }
}

var allMarkers: [CustomMarker] = [] // addMaker()에서 추가
var markerCount = 1 // 각 마커를 tag로 구분하기 위한 카운트 변수
