//
//  StaticData.swift
//  travelme
//
//  Created by DiepViCuong on 2/19/21.
//

import Foundation
import UIKit

struct StaticData{
    struct EditProfile{
        static let labelInfoSize: CGFloat = 20.0
        static let topBorderColor: UIColor = UIColor.lightGray
    }
    
    struct ProfileHeader {
        static let labelFontSize: CGFloat = 14
    }
    static let defaultBorderColor: CGColor = UIColor(white: 0, alpha: 0.2).cgColor
    static let defaultBorderWidth: CGFloat = 0.5
}
