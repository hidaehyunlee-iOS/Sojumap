//
//  CustonMarker.swift
//  Sojumap
//
//  Created by daelee on 2023/09/07.
//

import Foundation
import NMapsMap

class CustomMarker: NMFMarker {
    var title: String?
    var name: String?
    var address: String?
    var distanceKM: Double?
    var customUserInfo: [String: Any]?

    init(position: NMGLatLng, title: String?, name: String?, address: String?, distanceKM: Double? ,customUserInfo: [String: Any]? = nil) {
        super.init()
        self.position = position
        self.title = title
        self.name = name
        self.address = address
        self.distanceKM = distanceKM
        self.customUserInfo = customUserInfo
    }
}

var allMarkers: [CustomMarker] = [] // addMaker()에서 추가
var markerCount = 1 // 각 마커를 tag로 구분하기 위한 카운트 변수
