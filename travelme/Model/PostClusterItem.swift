//
//  PostClusterItem.swift
//  travelme
//
//  Created by DiepViCuong on 2/4/21.
//

import Foundation
import GoogleMapsUtils

class PostClusterItem: NSObject, GMUClusterItem{
    var position: CLLocationCoordinate2D
    var name: String
    var postOnMap: PostOnMap
    
    init(position: CLLocationCoordinate2D, name: String, postOnMap: PostOnMap) {
        self.position = position
        self.name = name
        self.postOnMap = postOnMap
    }
}
