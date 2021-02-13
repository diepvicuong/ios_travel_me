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
    let caption: String
    let createDate: Date
    let lat: Double
    let lon: Double
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.id = dictionary["id"] as? String ?? ""
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
        
        let timeStamp = dictionary["createDate"] as? Double ?? 0
        self.createDate = Date(timeIntervalSince1970: timeStamp)
        
        self.lat = dictionary["lat"] as? Double ?? 0
        self.lon = dictionary["lon"] as? Double ?? 0
    }
    
}

