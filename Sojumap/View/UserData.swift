//
//  UserData.swift
//  Sojumap
//
//  Created by daelee on 2023/09/05.
//

import Foundation

class UserData {
    let username: String
    let userEmail: String
    let signupTime: Date // 회원가입 시간 필요없으면 지우는걸로
    
    init(username: String, userEmail: String, signupTime: Date) {
        self.username = username
        self.userEmail = userEmail
        self.signupTime = signupTime
    }
}
