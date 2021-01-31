//
//  Trip.swift
//  travelme
//
//  Created by DiepViCuong on 1/27/21.
//

import Foundation
import FirebaseFirestore

class Post{
    var id: String
    
    let user: User
    let imageUrl: String
    let title: String
    let caption: String
    let createDate: Int64
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.id = dictionary["id"] as? String ?? ""
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
        self.title = dictionary["title"] as? String ?? ""
        
        self.createDate = dictionary["createDate"] as? Int64 ?? 0
    }
}

