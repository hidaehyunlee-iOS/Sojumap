//
//  PlaceDetailViewController.swift
//  Sojumap
//
//  Created by daelee on 2023/09/04.
//

import UIKit
import NMapsMap
import YoutubePlayer_in_WKWebView

class PlaceDetailViewController: UIViewController {

    @IBOutlet weak var playerView: WKYTPlayerView!
    
    let playVarsDic = ["playsinline": 1]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        playerView.load(withVideoId: "b3aKs29igcQ", playerVars: playVarsDic)
        playerView.delegate = self
        
    }
    

    
}


extension PlaceDetailViewController: WKYTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        playerView.playVideo()
    }
}
