//
//  Extensions.swift
//  Sojumap
//
//  Created by APPLE M1 Max on 2023/09/05.
//

import SwiftUI

extension String {
    var isValidCredential: Bool {
            let regex = "^(?=.*[a-zA-Z])(?=.*\\d).{5,}$"
            return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
        }
}
