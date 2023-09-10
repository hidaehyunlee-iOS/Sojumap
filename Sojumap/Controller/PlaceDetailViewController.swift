//
//  PlaceDetailViewController.swift
//  Sojumap
//
//  Created by daelee on 2023/09/04.
//

import UIKit
import NMapsMap
import WebKit
import SafariServices
import CoreLocation
import Alamofire
import SwiftyJSON

class PlaceDetailViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    // 영상 재생 view
    @IBOutlet weak var playerView: WKWebView?
  
    @IBOutlet weak var placeInformView: UIStackView?
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var mapView: NMFNaverMapView?
//    @IBOutlet weak var secondViewBottomConstraint: NSLayoutConstraint! // 두 번째 UIView의 하단 제약
    
    var isExpanded = true // 확장 상태를 추적하는 변수
    
    var videoData: VideoData? // 비디오 데이터 객체 가져오기
    
    // 전달 받은 데이터
    var videoId: String = ""
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var viewCnt: UILabel!
    @IBOutlet weak var hashtag: UILabel!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var urlBtn: UIButton!
    
    // 지오코딩 객체 생성
    let NAVER_GEOCODE_URL = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query="
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 디테일 페이지로 넘어올 때 full screen으로 보여지게 작업(메인 작업 완료 후 작업)
//        UIModalPresentationStyle.fullScreen
//        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: 100)
        // 스택뷰 초기 상태 설정
        placeInformView?.isHidden = false
        // ui 스타일 지정
        setUpStyle()
        // 데이터 받아오기
        setupData()
        // 유튜브 재생하기
        getVideo()
        // 지도 마커 받아오기
        configMap()
        
        
    }
    
    // 더보기 버튼
    @IBAction func toggleStackView(_ sender: UIButton) {
        // 첫 번째 Stack View의 숨김 상태 토글
//        placeInformView?.isHidden = !isExpanded
//
//        // 스택 뷰가 펼쳐져 있는지 확인하고 애니메이션으로 확장 또는 축소
//        UIView.animate(withDuration: 0.3) { [weak self] in
//            if let isExpanded = self?.isExpanded {
//                // 첫 번째 Stack View가 숨겨져 있는 경우 두 번째 UIView를 아래로 이동
//                self?.secondViewBottomConstraint.constant = isExpanded ? 0 : (self?.placeInformView?.frame.height ?? 0)
//                self?.view.layoutIfNeeded()
//            }
//        }
//
//        // 확장 상태 업데이트
//        isExpanded = !isExpanded
//
//        // 버튼 이미지 변경
//        isExpanded ? expandButton.setImage(UIImage(systemName: "chevron.down"), for: .normal) : expandButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)

    }
    
    // ui 설정
    func setUpStyle(){
        urlBtn.layer.cornerRadius = 6
        urlBtn.layer.masksToBounds = true
     
        videoTitle.numberOfLines = 2 // 두 줄까지만 표시하도록 설정
        videoTitle.lineBreakMode = .byTruncatingTail // 넘치는 텍스트는 생략하도록 설정
        
    }
    
    func setupData() {
        
        guard let data = videoData,
              let dataID = data.videoId,
              let dataTitle = data.title,
              let viewCount = data.releaseViewCount,
//              let hashtag = data.hashtags[],
              let name = data.videoInfo[safe: 0] ?? "",
              let addr = data.videoInfo[safe: 1] ?? ""
        else {return}
        
        urlBtn.addTarget(self, action: #selector(openLink), for: .touchUpInside)
       
        // 데이터 값 넣어주기
        videoId = dataID
        videoTitle.text = dataTitle
        viewCnt.text = viewCount
        
        if data.videoInfo.isEmpty == true {
            placeName.text = "** 식당 정보가 없습니다. **"
            address.text = ""
        }else {
            placeName.text = "🍽️ " + name
            address.text = addr
        }
         
    }
    
    @objc func openLink(sender: UITapGestureRecognizer) {
        
        guard let data = videoData,
              let url = data.videoInfo[2] else {return}
      
        if let url = URL(string: url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
}

// MARK: - extention

// 유튜브 영상 실행 설정
extension PlaceDetailViewController: WKNavigationDelegate, WKUIDelegate {
    
    func getVideo(){
        // YouTube 동영상의 임베드 코드
        // * autoplay=1 -> 동영상 자동 실행
        let embedCode = "<iframe width=\"100%\" height=\"100%\" src=\"https://www.youtube.com/embed/\(self.videoId)?autoplay=1\" frameborder=\"0\" allowfullscreen></iframe>"

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

// 지도 설정
extension PlaceDetailViewController: NMFMapViewDelegate {
   
    func configMap(){
        mapView?.mapView.delegate = self
        mapView?.showLocationButton = true
        mapView?.mapView.zoomLevel = 15
        
        guard let data = videoData,
              let addr = data.videoInfo[safe: 1] ?? ""
        else {return}
        
        let encodeAddress = addr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        convertAddressToCoordinate(address: encodeAddress)
    }
    
    // 주소에서 위도와 경도 알아내기
    func convertAddressToCoordinate(address: String?){
        let header1 = HTTPHeader(name: "X-NCP-APIGW-API-KEY-ID", value: NAVER_CLIENT_ID)
        let header2 = HTTPHeader(name: "X-NCP-APIGW-API-KEY", value: NAVER_CLIENT_SECRET)
        let headers = HTTPHeaders([header1, header2])
        
        AF.request(NAVER_GEOCODE_URL + address!, method: .get, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value as [String: Any]):
                let json = JSON(value)
                let data = json["addresses"]
                
                let lat = data[0]["y"].doubleValue
                let lon = data[0]["x"].doubleValue
                
                let coordinate = NMGLatLng(lat: lat, lng: lon)
                
                self.setMarker(at: coordinate)
                
            case .failure(let error):
                print(error.errorDescription ?? "")
            default:
                fatalError()
            }
            
        }
    }
    
    // 마커 생성
    func setMarker(at latlng: NMGLatLng){

        let marker = NMFMarker(position: latlng)
        
        guard let data = videoData,
              let name = data.videoInfo[safe: 0] else {return}
        
        marker.mapView = mapView?.mapView
        marker.captionRequestedWidth = 60
        marker.captionText =  name ?? ""
        
        // 마커가 있는 위치로 지도 화면을 이동
        let cameraUpdate = NMFCameraUpdate(scrollTo: latlng)
        mapView?.mapView.moveCamera(cameraUpdate)
    }
    
}
