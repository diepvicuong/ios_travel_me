//
//  PostOnMap.swift
//  travelme
//
//  Created by DiepViCuong on 2/4/21.
//

import Foundation


struct PostOnMap{
    var id: String
    
    var caption: String
    var lat: Double
    var lon: Double
    let imageUrl: String?
    let user: User
    
    init(post: Post) {
        self.id = post.id
        self.caption = post.caption
        self.user = post.user
        self.lat = post.lat
        self.lon = post.lon
        self.imageUrl = post.imageUrl
    }
}
