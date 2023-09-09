//
//  EditMyPageViewController.swift
//  Sojumap
//
//  Created by APPLE M1 Max on 2023/09/08.
//

import UIKit

class EditMyPageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    var myProfile: User?
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeyboardDismissRecognizer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupUI()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func setupUI() {
        guard let _myProfile = users.first(where: {$0.username == myInfo}) else { return }
        myProfile = _myProfile
        
        profileImageView.image = _myProfile.profilePhoto
        
        firstNameTextField.text = _myProfile.name.first
        lastNameTextField.text = _myProfile.name.last
        userNameTextField.text = _myProfile.username
    }
    
    private func resetUserTextField() {
        userNameTextField.text = ""
        userNameTextField.isUserInteractionEnabled = true
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        guard let newUsername = userNameTextField.text else { return }
        
        if newUsername != "", isValidUsername(newUsername) {
            if let newImage = selectedImage {
                profileImageView.image = newImage
                myProfile?.profilePhoto = newImage
            }
            myProfile?.name = (firstNameTextField.text ?? "", lastNameTextField.text ?? "")
            myProfile?.username = newUsername
            
            if let index = users.firstIndex(where: { $0.username == myInfo }) {
                users[index] = myProfile!
            }
            myInfo = newUsername
            
            dismiss(animated: true)
        } else {
            showInvalidUsernameAlert()
            resetUserTextField()
        }
    }
    
    func isValidUsername(_ username: String) -> Bool {
        return !users.contains(where: {$0.username != myProfile?.username && $0.username == username})
    }

    func showInvalidUsernameAlert() {
        let alert = UIAlertController(title: "Invalid Username", message: "The username is already taken or does not meet the required conditions.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func changePhotoButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            profileImageView.image = editedImage
            selectedImage = editedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 키보드 해제
    func setupKeyboardDismissRecognizer() {
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    
}
