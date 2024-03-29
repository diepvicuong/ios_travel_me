//
//  User.swift
//  travelme
//
//  Created by DiepViCuong on 1/23/21.
//

import Foundation
import FirebaseAuth

class User{
    let uid: String
    let username: String
    let email: String
    let phoneNumber: String
    let profileImageUrl: String?
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.username = dictionary["username"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.phoneNumber = dictionary["phoneNumber"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
    }
}
