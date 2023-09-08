//
//  MapTableViewController.swift
//  Sojumap
//
//  Created by daelee on 2023/09/07.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var placeAddrLabel: UILabel!
    @IBOutlet weak var placeNameLabel: UILabel!
}

class MapTableViewController: UIViewController {
    @IBOutlet weak var markerCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    @IBAction func mapViewButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        markerCountLabel.text = String(allMarkers.count)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.reloadData()
    }
}

extension MapTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMarkers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        
        let marker = allMarkers[indexPath.row]

        cell.placeNameLabel.text = marker.name
        cell.placeAddrLabel.text = marker.address

        return cell
    }
}
