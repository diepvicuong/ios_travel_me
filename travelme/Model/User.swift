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
    let profileImageUrl: String?
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
    }
}
