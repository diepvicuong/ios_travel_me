//
//  NumberExt.swift
//  travelme
//
//  Created by DiepViCuong on 2/10/21.
//

import Foundation
import UIKit

extension Double {
    func toInt() -> Int? {
        if self >= Double(Int.min) && self < Double(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
    
    func toInt64() -> Int64? {
        if self >= Double(Int64.min) && self < Double(Int64.max) {
            return Int64(self)
        } else {
            return nil
        }
    }
    
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
    
    var degreesToRadians : CGFloat {
        return CGFloat(self) * CGFloat(Double.pi) / 180.0
    }
}
