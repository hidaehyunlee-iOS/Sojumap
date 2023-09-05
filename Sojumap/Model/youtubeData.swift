//
//  youtubeData.swift
//  Sojumap
//
//  Created by t2023-m0067 on 2023/09/05.
//

import Foundation

class youtubeData {
    let url : String
    let Thumbnail : String
    let title : String
    let views : String //(조회수로 추가적인 작업 X, 문자열로 받아오기)
    let uploadDate : String //(원하는 형식으로 변경필요 "yyyy-MM-dd")
    let hashtag : String
    let information : String
    
    init(url: String, Thumbnail: String, title: String, views: String, uploadDate: String, hashtag: String, information: String) {
        self.url = url
        self.Thumbnail = Thumbnail
        self.title = title
        self.views = views
        self.uploadDate = uploadDate
        self.hashtag = hashtag
        self.information = information
    }
}
