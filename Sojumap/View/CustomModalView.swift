//
//  CustomModalView.swift
//  Sojumap
//
//  Created by daelee on 2023/09/05.
//

import UIKit

class CustomModalView: UIView {
    
    // UI 요소 정의
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0 // 여러 줄 텍스트 지원
        return label
    }()
    
    let roadAddrLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    let detailButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("자세히 보기", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    // 모달 뷰 초기화
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // UI 요소 배치 및 제약 조건 설정
    private func setupUI() {
        addSubview(nameLabel)
        addSubview(roadAddrLabel)
        addSubview(detailButton)
        
        // nameLabel 제약 조건 설정
        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        
        // roadAddrLabel 제약 조건 설정
        roadAddrLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        roadAddrLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        roadAddrLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        
        // detailButton 제약 조건 설정
        detailButton.topAnchor.constraint(equalTo: roadAddrLabel.bottomAnchor, constant: 16).isActive = true
        detailButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        // 모달 뷰의 높이 설정
        heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
}
