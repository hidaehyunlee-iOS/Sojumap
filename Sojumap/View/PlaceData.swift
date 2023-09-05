//
//  placeData.swift
//  Sojumap
//
//  Created by t2023-m0067 on 2023/09/05.
//

import Foundation

class PlaceData {
    let name: String // 장소이름
    let url: String
    let latitude: Double // 위도
    let longitude: Double // 경도
    
    init(name: String, url: String, latitude: Double, longitude: Double) {
        self.name = name
        self.url = url
        self.latitude = latitude
        self.longitude = longitude
    }
}
