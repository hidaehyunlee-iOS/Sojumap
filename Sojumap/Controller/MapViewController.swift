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

class MapViewController: UIViewController {

    let NAVER_GEOCODE_URL = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query="

    @IBAction func test(_ sender: Any) {
        let address = "서울특별시 강남구 강남대로 364"
        let encodedSearchName = address.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        convertAddressToCoordinate(address: encodedSearchName)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
                    let lat = data[0]["y"]
                    let lon = data[0]["x"]
                    
                    print("위도:",lat, "경도:",lon)
                case .failure(let error):
                    print(error.errorDescription ?? "")
                default :
                    fatalError()
                }
            }
    }
}
