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

let addresses = [
            "서울 중구 남대문로1길 11",
            "서울 강북구 삼각산로 130 1층",
            "서울 영등포구 도림로141다길 13-2",
            "서울 마포구 방울내로 82",
            "서울 중구 세종대로11길 26"
        ]

class MapViewController: UIViewController, NMFMapViewDelegate {
    @IBOutlet weak var naverMapView: NMFNaverMapView!
    let NAVER_GEOCODE_URL = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query="
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NMFNaverMapView delegate 설정
        naverMapView.mapView.delegate = self
        
        // 주소 배열을 순회하며 처리
        for address in addresses {
            let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            convertAddressToCoordinate(address: encodedAddress)
        }
    }
    
    // 주소를 위경도로 변환하는 함수
    func convertAddressToCoordinate(address: String?) {
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
                    let roadAddr = data[0]["roadAddress"]
                    let coordinate = NMGLatLng(lat: lat, lng: lon)
                    
                    print("위도:", lat, "경도:", lon, "도로명주소:", roadAddr)
                    
                    // 초기 카메라 위치를 마커가 있는 위치로 설정
                    self.addMarker(at: coordinate)
                    self.setInitialCameraPosition(at: coordinate)
                    
                case .failure(let error):
                    print(error.errorDescription ?? "")
                default :
                    fatalError()
                }
            }
    }
    
    // 마커 추가 함수
    func addMarker(at latlng: NMGLatLng) {
        let marker = NMFMarker() // !! 할일: 상속 받는 새 마커 클래스 만들기
        
        marker.position = latlng
        marker.mapView = naverMapView.mapView
    }
    
    // 초기 카메라 위치 설정 함수
    func setInitialCameraPosition(at latlng: NMGLatLng) {
        naverMapView.mapView.positionMode = .disabled
        naverMapView.mapView.moveCamera(NMFCameraUpdate(scrollTo: latlng))
    }
}
