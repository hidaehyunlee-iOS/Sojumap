//
//  VideoTableHeaderView.swift
//  Sojumap
//
//  Created by Macbook on 2023/09/10.
//

import UIKit

class VideoTableHeaderView: UIView {
    
    let KindOfNewDate: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 13
        button.backgroundColor = Mycolor.searchBar
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 13)]
        let attributedTitle = NSAttributedString(string: "최신순", attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    let KindOfOldDate: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 13
        button.backgroundColor = Mycolor.searchBar
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 13)]
        let attributedTitle = NSAttributedString(string: "날짜순", attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    let KindOfPopular: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 13
        button.backgroundColor = Mycolor.searchBar
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 13)]
        let attributedTitle = NSAttributedString(string: "인기순", attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    let KindOfWish: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 13
        button.backgroundColor = Mycolor.searchBar
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 13)]
        let attributedTitle = NSAttributedString(string: "저장", attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    lazy var buttonSV: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [KindOfPopular ,KindOfNewDate, KindOfOldDate, KindOfWish])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = 5
        sv.alignment = .fill
        sv.distribution = .fillEqually
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(buttonSV)
        autoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func autoLayout() {
        NSLayoutConstraint.activate([
            buttonSV.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 17),
            buttonSV.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -60),
            buttonSV.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 5),
            buttonSV.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

        ])
    }
    
}
