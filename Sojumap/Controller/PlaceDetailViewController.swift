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
    // 영상 재생 view
    @IBOutlet weak var playerView: WKYTPlayerView!
    // 영상 재생 시, 전체 화면 되지 않고 현재 뷰에서 재생
    let playVarsDic = ["playsinline": 1]
    
    @IBOutlet weak var placeInformView: UIStackView!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var mapView: NMFNaverMapView!
    @IBOutlet weak var secondViewBottomConstraint: NSLayoutConstraint! // 두 번째 UIView의 하단 제약
    
    var isExpanded = true // 확장 상태를 추적하는 변수
    
    override func viewDidLoad() {
        super.viewDidLoad()

        playerSetting()
        
        // 스택뷰 초기 상태 설정
        placeInformView.isHidden = true
        
    }
    
    // 영상 재생 설정
    func playerSetting() {
        playerView.load(withVideoId: "b3aKs29igcQ", playerVars: playVarsDic)
        playerView.delegate = self
    }
    
    @IBAction func toggleStackView(_ sender: UIButton) {
        // 첫 번째 Stack View의 숨김 상태 토글
        placeInformView.isHidden = !isExpanded
        
        // 스택 뷰가 펼쳐져 있는지 확인하고 애니메이션으로 확장 또는 축소
        UIView.animate(withDuration: 0.3) { [weak self] in
            if let isExpanded = self?.isExpanded {
                // 첫 번째 Stack View가 숨겨져 있는 경우 두 번째 UIView를 아래로 이동
                self?.secondViewBottomConstraint.constant = isExpanded ? 0 : (self?.placeInformView.frame.height ?? 0)
                self?.view.layoutIfNeeded()
            }
        }
        
        // 확장 상태 업데이트
        isExpanded = !isExpanded
        
        // 버튼 텍스트 변경 -> 후에 이미지로 변경
        let buttonText = isExpanded ? "펼치기" : "축소"
        expandButton.setTitle(buttonText, for: .normal)
    }
    
}

// MARK: - extention

extension PlaceDetailViewController: WKYTPlayerViewDelegate {
    // 뷰컨트롤러 실행 시 영상 자동 재생
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        playerView.playVideo()
    }
}
