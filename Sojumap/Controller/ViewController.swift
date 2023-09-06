//
//  ViewController.swift
//  Sojumap
//
//  Created by daelee on 2023/09/04.
//

import UIKit

class ViewController: UIViewController {
    
    let videoManager = ThreeMealVideo.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        
    }
    
    func setupData() {
        
        videoManager.fetchChannelData { result in
            guard let result = result else { return }
            self.videoManager.fetchVideoData(playlistID: result) { videoResult in

                
            }
        }
    }
    
}

