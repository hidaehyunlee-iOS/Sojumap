//
//  MapViewController.swift
//  Sojumap
//
//  Created by daelee on 2023/09/04.
//

import UIKit
import NMapsMap
import CoreLocation
import Alamofire
import SwiftyJSON
import SwiftSoup

class CustomMarker: NMFMarker {
    var title: String?
    var name: String?
    var address: String?
    var customUserInfo: [String: Any]?

    init(position: NMGLatLng, title: String?, name: String?, address: String?, customUserInfo: [String: Any]? = nil) {
        super.init()
        self.position = position
        self.title = title
        self.name = name
        self.address = address
        self.customUserInfo = customUserInfo
    }
}


class MapViewController: UIViewController, NMFMapViewDelegate {
    @IBOutlet weak var naverMapView: NMFNaverMapView!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var placeAddr: UILabel!
    
    let NAVER_GEOCODE_URL = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query="
    var initialMarkerName: String?
    var initialMarkerAddress: String?
    var allMarkers: [CustomMarker] = [] // addMaker()에서 추가
    var count = 1 // 각 마커를 tag로 구분하기 위한 카운트 변수

    override func viewDidLoad() {
        super.viewDidLoad()
        setMap()

        naverMapView.mapView.delegate = self
    }
    
    private func setMap() {
        naverMapView.showLocationButton = true // 현재위치 버튼
        naverMapView.mapView.zoomLevel = 11 // 값이 클수록 지도 확대

        // 비디오 데이터 처리
        for dummyData in dummyDataList {
            guard let title = dummyData["Title"] as? String,
                  let descriptions = dummyData["Description"] as? [String], descriptions.count >= 2,
                  let name = descriptions.first,
                  let address = descriptions.last,
                  let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                continue
            }
            
            convertAddressToCoordinate(title: title, name: name, address: encodedAddress)
        }
    }
    
    // 주소를 위경도로 변환하는 함수
    func convertAddressToCoordinate(title: String?, name: String?, address: String?) {
        let header1 = HTTPHeader(name: "X-NCP-APIGW-API-KEY-ID", value: NAVER_CLIENT_ID)
        let header2 = HTTPHeader(name: "X-NCP-APIGW-API-KEY", value: NAVER_CLIENT_SECRET)
        let headers = HTTPHeaders([header1,header2])
        
        AF.request(NAVER_GEOCODE_URL + address!, method: .get, encoding: URLEncoding.default, headers: headers).validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value as [String:Any]):
                    let json = JSON(value)
                    let data = json["addresses"]
                    
                    let lat = data[0]["y"].doubleValue
                    let lon = data[0]["x"].doubleValue
                    let roadAddr = data[0]["roadAddress"].stringValue
                    let coordinate = NMGLatLng(lat: lat, lng: lon)
                    
                    print("위도:", lat, "경도:", lon, "도로명주소:", roadAddr)
                    // 마커 생성
                    self.addMarker(at: coordinate, title: title, name: name, address: roadAddr)
                    
                case .failure(let error):
                    print(error.errorDescription ?? "")
                default :
                    fatalError()
                }
            }
    }
    
    // 마커 추가 함수
    func addMarker(at latlng: NMGLatLng, title: String?, name: String?, address: String?) {
        let marker = CustomMarker(position: latlng, title: title, name: name, address: address, customUserInfo: ["tag" : count])
        
        count += 1
        allMarkers.append(marker)
        
        for marker in allMarkers {
            marker.touchHandler = { (overlay) -> Bool in
                if let customMarker = overlay as? CustomMarker,
                   let tag = customMarker.customUserInfo?["tag"] as? Int {
                    print("마커 \(tag) 터치됨")
                    
                    // 마커를 클릭했을 때 placeName.text와 placeAddr.text를 업데이트
                    self.placeName.text = customMarker.name
                    self.placeAddr.text = customMarker.address
                }
                return false
            }
        }

        marker.mapView = naverMapView.mapView
        marker.captionRequestedWidth = 60 // 캡션 너비
        marker.captionText = name ?? "" // 캡션 네임
        
        // 하단 뷰에는 제일 처음 생성된 마커 정보만 표시
        if initialMarkerName == nil && initialMarkerAddress == nil {
            initialMarkerName = name
            initialMarkerAddress = address
            
            // *이후 마커 클릭시 한번 더 업데이트 필요
            placeName.text = marker.name
            placeAddr.text = marker.address
            
            setInitialCameraPosition(at: latlng)
        }
    }
    
    // 초기 카메라 위치 설정 함수
    func setInitialCameraPosition(at latlng: NMGLatLng) {
        naverMapView.mapView.positionMode = .disabled
        naverMapView.mapView.moveCamera(NMFCameraUpdate(scrollTo: latlng))
    }
}
