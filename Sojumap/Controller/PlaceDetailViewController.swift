//
//  PlaceDetailViewController.swift
//  Sojumap
//
//  Created by daelee on 2023/09/04.
//

import UIKit
import NMapsMap
import WebKit


class PlaceDetailViewController: UIViewController {
    // 영상 재생 view
    @IBOutlet weak var playerView: WKWebView?
    // 영상 재생 시, 전체 화면 되지 않고 현재 뷰에서 재생
//    let playVarsDic = ["playsinline": 1]
    
    @IBOutlet weak var placeInformView: UIStackView?
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var mapView: NMFNaverMapView!
    @IBOutlet weak var secondViewBottomConstraint: NSLayoutConstraint! // 두 번째 UIView의 하단 제약
    
    var isExpanded = true // 확장 상태를 추적하는 변수
    
    // 필요한 변수
    // videoid, 썸네일, 제목, 조회수, 해시태그, 식당이름, 식당 주소, 식당url(네이버 링크)
    var videoId: String = ""
    var thumnail: String = ""
    var videoTitle: String = ""
    var viewCnt: String = ""
    var hashtag: String = ""
    var placeName: String = ""
    var address: String = ""
    var placeUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 디테일 페이지로 넘어올 때 full screen으로 보여지게 작업(메인 작업 완료 후 작업)
//        UIModalPresentationStyle.fullScreen
        
        getVideo()
     
        // 스택뷰 초기 상태 설정
        placeInformView?.isHidden = true
        
    }
    
    // 더보기 버튼
    @IBAction func toggleStackView(_ sender: UIButton) {
        // 첫 번째 Stack View의 숨김 상태 토글
        placeInformView?.isHidden = !isExpanded
        
        // 스택 뷰가 펼쳐져 있는지 확인하고 애니메이션으로 확장 또는 축소
        UIView.animate(withDuration: 0.3) { [weak self] in
            if let isExpanded = self?.isExpanded {
                // 첫 번째 Stack View가 숨겨져 있는 경우 두 번째 UIView를 아래로 이동
                self?.secondViewBottomConstraint.constant = isExpanded ? 0 : (self?.placeInformView?.frame.height ?? 0)
                self?.view.layoutIfNeeded()
            }
        }
        
        // 확장 상태 업데이트
        isExpanded = !isExpanded
        
        // 버튼 이미지 변경
        isExpanded ? expandButton.setImage(UIImage(systemName: "chevron.down"), for: .normal) : expandButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
    
    }
    
}

// MARK: - extention

// 유튜브 영상 실행 설정
extension PlaceDetailViewController: WKNavigationDelegate, WKUIDelegate {
    
    func getVideo(){
        // YouTube 동영상의 임베드 코드
        let videoID = "b3aKs29igcQ"
        // * autoplay=1 -> 동영상 자동 실행
        let embedCode = "<iframe width=\"100%\" height=\"100%\" src=\"https://www.youtube.com/embed/\(videoID)?autoplay=1\" frameborder=\"0\" allowfullscreen></iframe>"

        // 임베드 코드를 HTML 형식으로 래핑
        let html = """
        <html>
        <head>
        <style>
        body { margin: 0; }
        </style>
        </head>
        <body>
        \(embedCode)
        </body>
        </html>
        """
        
        playerView?.allowsBackForwardNavigationGestures = true
        playerView?.allowsLinkPreview = true
       
        playerView?.uiDelegate = self
        playerView?.navigationDelegate = self
        
        // WKWebView에 HTML 로드
        playerView?.loadHTMLString(html, baseURL: nil)

    }
    
    // WKNavigationDelegate 메서드 중 하나인 didFinish를 사용하여 로딩 완료 후 추가 작업 수행 가능
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("YouTube 동영상 로딩 완료")

        // 로딩이 완료되면 크기를 자동으로 조절하도록 설정
        webView.sizeToFit()

    }
    
}
