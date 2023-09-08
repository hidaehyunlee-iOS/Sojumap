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
    @IBOutlet weak var placeName: UILabel?
    @IBOutlet weak var placeAddr: UILabel?
    @IBOutlet weak var distanceInKilometers: UILabel?
    
    let NAVER_GEOCODE_URL = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query="
    var initialMarkerName: String?
    var initialMarkerAddress: String?
    let locationManager = CLLocationManager()
    
    @IBAction func showListButton(_ sender: UIBarButtonItem) {
        let storyBoard = UIStoryboard(name: "MapTableViewController", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "MapTableViewController") as! MapTableViewController
        //self.present(vc, animated: false, completion: nil)
        
        self.navigationController?.pushViewController(vc, animated: true)
        // self.present(MapTableVC, animated: false, completion: nil)
    }
    
    @IBAction func detailPageButton(_ sender: UIButton) {
        let placeDetailVC = PlaceDetailViewController()
        
        // 선택된 마커 정보 식별해야됨
        //            placeDetailVC.markerTitle = "self.markerTitle"
        //            placeDetailVC.markerName = "self.markerNamex"
        //            placeDetailVC.markerAddress = "self.markerAddress"
        
        self.present(placeDetailVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
            super.viewDidLoad()
            setMap()
            
            naverMapView?.mapView.delegate = self
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        private func setMap() {
            naverMapView?.showLocationButton = true
            naverMapView?.mapView.zoomLevel = 11
            
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
        
        func convertAddressToCoordinate(title: String?, name: String?, address: String?) {
            let header1 = HTTPHeader(name: "X-NCP-APIGW-API-KEY-ID", value: NAVER_CLIENT_ID)
            let header2 = HTTPHeader(name: "X-NCP-APIGW-API-KEY", value: NAVER_CLIENT_SECRET)
            let headers = HTTPHeaders([header1, header2])
            
            AF.request(NAVER_GEOCODE_URL + address!, method: .get, encoding: URLEncoding.default, headers: headers).validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let value as [String: Any]):
                        let json = JSON(value)
                        let data = json["addresses"]
                        
                        let lat = data[0]["y"].doubleValue
                        let lon = data[0]["x"].doubleValue
                        let roadAddr = data[0]["roadAddress"].stringValue
                        let coordinate = NMGLatLng(lat: lat, lng: lon)
                        
                        self.addMarker(at: coordinate, title: title, name: name, address: roadAddr)
                        
                    case .failure(let error):
                        print(error.errorDescription ?? "")
                    default:
                        fatalError()
                    }
                }
        }
        
        func addMarker(at latlng: NMGLatLng, title: String?, name: String?, address: String?) {
            let marker = CustomMarker(position: latlng, title: title, name: name, address: address, distance: nil, customUserInfo: ["tag": markerCount])
            
            markerCount += 1
            allMarkers.append(marker)
            
            for marker in allMarkers {
                marker.touchHandler = { (overlay) -> Bool in
                    if let customMarker = overlay as? CustomMarker,
                       let tag = customMarker.customUserInfo?["tag"] as? Int {
                        self.placeName?.text = customMarker.name
                        self.placeAddr?.text = customMarker.address
                        self.calculateDistance(marker: customMarker)
                    }
                    return false
                }
            }
            
            marker.mapView = naverMapView?.mapView
            marker.captionRequestedWidth = 60
            marker.captionText = name ?? ""
            
            if initialMarkerName == nil && initialMarkerAddress == nil {
                initialMarkerName = name
                initialMarkerAddress = address
                
                placeName?.text = marker.name
                placeAddr?.text = marker.address
                
                setInitialCameraPosition(at: latlng)
                calculateDistance(marker: marker)
            }
        }
        
        func calculateDistance(marker: CustomMarker) {
            guard let currentLocation = locationManager.location else {
                return
            }
            
            print(currentLocation.coordinate.latitude)
            print(currentLocation.coordinate.longitude)

            
            let markerLocation = CLLocation(latitude: marker.position.lat, longitude: marker.position.lng)
            let distanceM = currentLocation.distance(from: markerLocation)
            let distanceKM = distanceM / 1000.0
            
            distanceInKilometers?.text = String(format: "%.2f km", distanceKM)
        }
        
        func setInitialCameraPosition(at latlng: NMGLatLng) {
            naverMapView?.mapView.positionMode = .disabled
            naverMapView?.mapView.moveCamera(NMFCameraUpdate(scrollTo: latlng))
        }
    }
