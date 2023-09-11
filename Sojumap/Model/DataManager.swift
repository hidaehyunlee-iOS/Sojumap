//
//  DataManager.swift
//  Sojumap
//
//  Created by APPLE M1 Max on 2023/09/05.
//
import Foundation
import UIKit

struct User {
    var username: String
    var name: (first: String, last: String) = ("","")
    var profilePhoto: UIImage
    var password: String = ""
}

var users: [User] = [User(username: "soju1",profilePhoto: UIImage(systemName: "person")!, password: "soju1")]




var myInfo: String?

