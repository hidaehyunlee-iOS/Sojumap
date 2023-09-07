//
//  MapTableViewController.swift
//  Sojumap
//
//  Created by daelee on 2023/09/07.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeAddrLabel: UILabel!
}

class MapTableViewController: UIViewController {
    @IBOutlet weak var markerCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("vc")
    }
}

extension MapTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return allMarkers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        
        // 해당 indexPath의 CustomMarker 인스턴스 가져옴
        let marker = allMarkers[indexPath.row]
        
        cell.placeNameLabel.text = marker.name
        cell.placeAddrLabel.text = marker.address

        return cell
    }
}
