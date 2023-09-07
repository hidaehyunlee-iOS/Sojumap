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

    init(position: NMGLatLng, title: String?, name: String?, address: String?) {
        super.init()
        self.position = position
        self.title = title
        self.name = name
        self.address = address
    }
}

class MapViewController: UIViewController, NMFMapViewDelegate {
    @IBOutlet weak var naverMapView: NMFNaverMapView!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var placeAddr: UILabel!
    
    let NAVER_GEOCODE_URL = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query="
    // let customModalView = CustomModalView() // CustomModalView 인스턴스를 생성
    var initialMarkerName: String?
    var initialMarkerAddress: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setMap()

        naverMapView.mapView.delegate = self
    }
    
    private func setMap() {
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
        let marker = CustomMarker(position: latlng, title: title, name: name, address: address)
        
        marker.mapView = naverMapView.mapView
        
        // 제일 처음 생성된 마커 정보만 표시
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
