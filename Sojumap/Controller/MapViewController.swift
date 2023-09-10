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

class MapViewController: UIViewController, NMFMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var naverMapView: NMFNaverMapView?
    @IBOutlet weak var placeNameLabel: UILabel?
    @IBOutlet weak var placeAddrLabel: UILabel?
    @IBOutlet weak var distanceInKilometers: UILabel?
    
    let NAVER_GEOCODE_URL = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query="
    var initialMarkerName: String?
    var initialMarkerAddress: String?
    var initialDistanceInKilometers: String?
    let locationManager = CLLocationManager()
    let saveManager = SaveDatas.shared

    
    @IBAction func showListButton(_ sender: UIBarButtonItem) {
        let storyBoard = UIStoryboard(name: "MapTableViewController", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "MapTableViewController") as! MapTableViewController
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func detailPageButton(_ sender: UIButton) {
        print("detailPageButton: clicked")
        // 1. 선택된 마커 정보 추출
//        if let selectedMarker = getSelectedMarker() {
//            // 2. PlaceDetailViewController 인스턴스 생성
//            let placeDetailVC = PlaceDetailViewController()
//
//            // 3. 선택된 마커의 정보를 PlaceDetailViewController 프로퍼티에 할당
//            placeDetailVC.videoId = selectedMarker.videoId ?? ""
//            placeDetailVC.thumnail = selectedMarker.thumbnail ?? ""
//            placeDetailVC.videoTitle = selectedMarker.videoTitle ?? ""
//            placeDetailVC.viewCnt = selectedMarker.viewCnt ?? ""
//            placeDetailVC.placeName = selectedMarker.placeName ?? ""
//            placeDetailVC.address = selectedMarker.address ?? ""
//            placeDetailVC.placeUrl = selectedMarker.placeUrl ?? ""
//
//            // PlaceDetailViewController를 화면에 표시
//            self.present(placeDetailVC, animated: true, completion: nil)
//        }
    }
    
//    // 선택된 마커를 가져오는 함수 (선택된 마커가 없으면 nil 반환)
//    func getSelectedMarker() -> CustomMarker? {
//        if let selectedMarkerIndex = getSelectedMarkerIndex() {
//            return allMarkers[selectedMarkerIndex]
//        }
//
//        return nil
//    }
    
//    func getSelectedMarkerIndex() -> Int? {
//        // 선택된 마커의 식당 이름을 기반으로 마커를 식별
//        if let index = allMarkers.firstIndex(where: { $0.placeName == selectedPlaceName }) {
//            return index // 선택된 마커의 인덱스 반환
//        }
//
//        return nil // 선택된 마커가 없으면 nil 반환
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configMap()
        configLocation()
    }
    
    private func configMap() {
        naverMapView?.mapView.delegate = self
        naverMapView?.showLocationButton = true
        naverMapView?.mapView.zoomLevel = 11
        
        for data in saveManager.saveMemoList {
            
            guard data.videoInfo.count >= 3,
                let videoId = data.videoId,
                let thumbnail = data.thumbnail,
                let videoTitle = data.title,
                let viewCnt = data.viewCount,
                let placeName = data.videoInfo[safe: 0] ?? "** 식당 정보가 없습니다. **",
                let address = data.videoInfo[safe: 1] ?? "",
                let placeUrl = data.videoInfo[safe: 2] ?? ""
            else {
                continue
            }
            
            //let testAddr = "서울 강동구 천호동 397-399"

            //guard let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
            // let encodedAddress = address.replacingOccurrences(of: "%25", with: "%")

            
            let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            //print("그냥 주소: \(address)")
            //print("인코딩 주소: \(encodedAddress)")
            convertAddressToCoordinate(videoId: videoId, thumbnail: thumbnail, videoTitle: videoTitle, viewCnt: viewCnt, placeName: placeName, address: encodedAddress, placeUrl: placeUrl)
        }
    }
    
    private func configLocation() {
        locationManager.delegate = self // 델리게이트 설정
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // 거리 정확도 설정
        locationManager.requestWhenInUseAuthorization() // 사용자에게 허용 받기 alert 띄우기
        
        // 위치 사용을 허용하면 현재 위치 정보를 가져옴
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        else {
            print("위치 서비스 허용 off")
        }
    }
    
    func convertAddressToCoordinate(videoId: String?, thumbnail: String?, videoTitle: String?, viewCnt: String?, placeName: String?, address: String?, placeUrl: String?) {
        let header1 = HTTPHeader(name: "X-NCP-APIGW-API-KEY-ID", value: NAVER_CLIENT_ID)
        let header2 = HTTPHeader(name: "X-NCP-APIGW-API-KEY", value: NAVER_CLIENT_SECRET)
        let headers = HTTPHeaders([header1, header2])

        AF.request(NAVER_GEOCODE_URL + address!, method: .get, headers: headers).validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value as [String: Any]):
                    let json = JSON(value)
                    let data = json["addresses"]
                    
                    let lat = data[0]["y"].doubleValue
                    let lon = data[0]["x"].doubleValue
                    //print("lat \(lat), lon: \(lon)")

                    let roadAddr = data[0]["roadAddress"].stringValue
                    let coordinate = NMGLatLng(lat: lat, lng: lon)
                    
                    // print("convertAddressToCoordinate: \(coordinate), \(videoTitle!), \(placeName!), \(roadAddr)")
                    //print("convertAddressToCoordinate, laatlan \(coordinate)")

                    self.setMarkers(at: coordinate, videoId: videoId!, thumbnail: thumbnail!, videoTitle: videoTitle!, viewCnt: viewCnt!, placeName: placeName!, address: roadAddr, placeUrl: placeUrl!)
                    
                case .failure(let error):
                    print(error.errorDescription ?? "")
                default:
                    fatalError()
                }
            }
    }
    
    func setInitialCameraPosition(at latlng: NMGLatLng) {
        naverMapView?.mapView.positionMode = .disabled
        naverMapView?.mapView.moveCamera(NMFCameraUpdate(scrollTo: latlng))
    }
    
    func setMarkers(at latlng: NMGLatLng, videoId: String?, thumbnail: String?, videoTitle: String?, viewCnt: String?, placeName: String?, address: String?, placeUrl: String?) {
        //print("setMarkers, laatlan \(latlng)")
        //print("setMarkers: \(latlng), \(videoTitle), \(placeName), \(address)")
        
        // 옵셔널 바인딩을 사용하여 옵셔널 값을 추출하고 안전하게 할당
        guard let videoId = videoId,
              let thumbnail = thumbnail,
              let videoTitle = videoTitle,
              let viewCnt = viewCnt,
              let placeName = placeName,
              let address = address,
              let placeUrl = placeUrl else {
            print("옵셔널 값이 nil입니다.")
            return
        }
        
//        print("videoId: \(videoId)")
//        print("thumbnail: \(thumbnail)")
//        print("videoTitle: \(videoTitle)")
//        print("viewCnt: \(viewCnt)")
//        print("placeName: \(placeName)")
//        print("address: \(address)")
//        print("placeUrl: \(placeUrl)")

        // 여기에 문제가 있음 ‼️
        let marker = CustomMarker(position: latlng, videoId: videoId, thumbnail: thumbnail, videoTitle: videoTitle, viewCnt: viewCnt, placeName: placeName, address: address, placeUrl: placeUrl, distanceKM: nil, customUserInfo: ["tag": markerCount])
        
        print("marker: \(marker.position), \(marker.videoTitle), \(marker.placeName), \(marker.address)")
        
        markerCount += 1
        //print("markerCount \(markerCount)")
        allMarkers.append(marker)
        //print(allMarkers)
        
        
        marker.touchHandler = { (overlay) -> Bool in
            if let customMarker = overlay as? CustomMarker,
               let tag = customMarker.customUserInfo?["tag"] as? Int {
                self.placeNameLabel?.text = customMarker.placeName
                self.placeAddrLabel?.text = customMarker.address
                self.distanceInKilometers?.text = self.calculateAndSetDistance(marker: customMarker) // 터치했을 때 올바른 거리 계산용
            }
            return false
        }
        
        calculateAndSetDistance(marker: marker) // 테이블뷰에 보여줄 거리 계산용

        marker.mapView = naverMapView?.mapView
        marker.captionRequestedWidth = 60
        marker.captionText = placeName
        
        setInitalMapView(marker: marker, latlng: latlng)
    }
    
    func setInitalMapView(marker: CustomMarker, latlng: NMGLatLng) {
        if initialMarkerName == nil && initialMarkerAddress == nil && initialDistanceInKilometers == nil{ // 초기값 세팅
            initialMarkerName = marker.placeName
            initialMarkerAddress = marker.address
            initialDistanceInKilometers = calculateAndSetDistance(marker: marker)

            placeNameLabel?.text = initialMarkerName
            placeAddrLabel?.text = initialMarkerAddress
            distanceInKilometers?.text = initialDistanceInKilometers
            
            setInitialCameraPosition(at: latlng)
        }
    }
    
    func calculateAndSetDistance(marker: CustomMarker) -> String {
        guard let currentLocation = locationManager.location else {
            return "" // 현재 위치를 불러올 수 없습니다.
        }
        
        let markerLocation = CLLocation(latitude: marker.position.lat, longitude: marker.position.lng)
        let distanceM = currentLocation.distance(from: markerLocation)
        
        marker.distanceKM = distanceM / 1000.0
        
        return String(format: "%.2f km", marker.distanceKM!)
    }
    
    
    // 위치 정보 계속 업데이트 -> 위도 경도 받아옴
    //    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        print("위치 업데이트")
    //        if let location = locations.first {
    //            print("위도: \(location.coordinate.latitude)")
    //            print("경도: \(location.coordinate.longitude)")
    //        }
    //    }
    
    // 위치 가져오기 실패
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
