//
//  ViewController11.swift
//  Sojumap
//
//  Created by APPLE M1 Max on 2023/09/08.
//

import UIKit


class MypageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var MypageViewNavigationItem: UINavigationItem!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var postsCollectionView: UICollectionView!
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        guard let myProfile = users.first(where: {$0.username == myInfo!}) else { return }
        
        MypageViewNavigationItem.title = myProfile.username
        
        profileImageView.image = myProfile.profilePhoto
        //        profileImageView.circleImage = true
        
        
        fullnameLabel.text = myProfile.name.last + myProfile.name.first == "" ? " " : myProfile.name.last + myProfile.name.first
        
        editProfileButton.layer.cornerRadius = 5
        editProfileButton.layer.borderWidth = 0.5
        editProfileButton.layer.borderColor = UIColor.lightGray.cgColor
        
        
        // 더보기/접기 글씨 없음, 라벨 전체 터치됨
        func isTextOverflowing(_ label: UILabel) -> Bool {
            let textLength = label.text?.count ?? 0
            let textHeight = label.text?.boundingRect(with: CGSize(width: label.frame.width, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font : label.font!], context: nil).height ?? 0
            return textLength > 0 && textHeight > label.frame.height
        }
        
        func updateLabelLayout(_ label: UILabel) {
            if isTextOverflowing(label) {
                label.lineBreakMode = .byTruncatingTail
                label.isUserInteractionEnabled = true
            } else {
                label.lineBreakMode = .byWordWrapping
                label.isUserInteractionEnabled = false
                label.gestureRecognizers?.removeAll()
                let heightConstraint = label.heightAnchor.constraint(equalToConstant: 54)
                heightConstraint.isActive = true
            }
        }
        
        
//        @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
//            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//            let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { _ in
//                self.confirmLogout()
//            }
            
//            alertController.addAction(cancelAction)
//            alertController.addAction(logoutAction)
//
//            present(alertController, animated: true, completion: nil)
//        }
//
//        func confirmLogout() {
//            let confirmAlertController = UIAlertController(title: "Confirm Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
//
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//            let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { _ in
//                self.performLogout()
//            }
//
//            confirmAlertController.addAction(cancelAction)
//            confirmAlertController.addAction(confirmAction)
//
//            present(confirmAlertController, animated: true, completion: nil)
//        }
        
        func performLogout() {
            performSegue(withIdentifier: "toLoginVC", sender: nil)
        }
        
    }
    
}
