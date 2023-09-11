//
//  MapTableViewController.swift
//  Sojumap
//
//  Created by daelee on 2023/09/07.
//

import UIKit
import SafariServices

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var placeAddrLabel: UILabel!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeDistance: UILabel?
}

class MapTableViewController: UIViewController {
    var sortByDistance = false // true면 거리순으로 보여줌
    
    @IBOutlet weak var markerCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var popUpButton: UIButton!
    
    @IBAction func mapViewButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configPopUpButton()

        navigationItem.hidesBackButton = true
        
        markerCountLabel.text = String(allMarkers.count)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.reloadData()
    }
    
    private func configPopUpButton() {
        let popUpButtonClosure = { (action: UIAction) in
            self.sortByDistance.toggle() // bool 토글
            
            if self.sortByDistance {
                // 거리순
                allMarkers.sort { (marker1, marker2) -> Bool in
                    return marker1.distanceKM! < marker2.distanceKM! // *강제언래핑 바꾸기
                }
            } else {
                // 등록순 (tag값 이용)
                allMarkers.sort { (marker1, marker2) -> Bool in
                    guard let tag1 = marker1.customUserInfo?["tag"] as? Int,
                          let tag2 = marker2.customUserInfo?["tag"] as? Int else {
                        return false
                    }
                    return tag1 < tag2
                }
            }
            
            self.tableView.reloadData()
        }
        
        popUpButton.menu = UIMenu(title: "정렬", children: [
            UIAction(title: "등록순", handler: popUpButtonClosure),
            UIAction(title: "거리순", handler: popUpButtonClosure),
        ])
        popUpButton.showsMenuAsPrimaryAction = true
    }
}

extension MapTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMarkers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        
        let marker = allMarkers[indexPath.row]
        
        cell.placeNameLabel.text = marker.placeName
        cell.placeAddrLabel.text = marker.address
        if let distanceKM = marker.distanceKM { // 거리는 바인딩 필요
            cell.placeDistance?.text = String(format: "%.2f km", distanceKM)
        } else {
            cell.placeDistance?.text = ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let marker = allMarkers[indexPath.row]
        
        if let url = URL(string: marker.placeUrl ?? "") {
            let safariVC = SFSafariViewController(url: url)
            self.present(safariVC, animated: true, completion: nil)
        }
        self.tableView.reloadData()
    }
}
