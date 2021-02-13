//
//  LocationUtils.swift
//  travelme
//
//  Created by DiepViCuong on 2/9/21.
//

import Foundation
import GoogleMaps
import Contacts


class LocationUtils{
    //https://stackoverflow.com/a/41358550
    static func getAddressFromLocation(lat: Double, lon: Double, completion: @escaping (String?)-> ()){
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: lat, longitude: lon), preferredLocale: nil){placeMarks, error in
            guard let place = placeMarks?.first else {
                    print("No placemark from Apple: \(String(describing: error))")
                    return
                }
            
//            print("country: \(place.country)")
//            print("locality: \(place.locality)")
//            print("subLocality: \(place.subLocality)")
//            print("thoroughfare: \(place.thoroughfare)")
//            print("postalCode: \(place.postalCode)")
//            print("subThoroughfare: \(place.subThoroughfare)")
//            print("administrativeArea: \(place.administrativeArea)")
//            print("subAdministrativeArea: \(place.subAdministrativeArea)")
//            print("isoCountryCode: \(place.isoCountryCode)")
//            print("inlandWater: \(place.inlandWater)")
//            print("ocean: \(place.ocean)")
//            print("areasOfInterest: \(place.areasOfInterest)")

            
            var addressString : String = ""
            if place.thoroughfare != nil {
                addressString = addressString + place.thoroughfare! + ", "
            }
            if place.subLocality != nil {
                addressString = addressString + place.subLocality! + ", "
            }
            if place.subAdministrativeArea != nil && place.subAdministrativeArea != place.subLocality{
                addressString += place.subAdministrativeArea! + ", "
            }
            if place.administrativeArea != nil {
                addressString = addressString + place.administrativeArea! + ", "
            }
            if place.country != nil {
                addressString = addressString + place.country!
            }
            
            if !addressString.isEmpty{
                completion(addressString)
            }else{
                completion(LocationUtils.converDMS(lat: lat, lon: lon, breakline: false))
            }
        }
    }
    static func toDegreesMinutesAndSecond(coordinate: Double) -> String{
        let coordinateAbs = abs(coordinate)
        let degrees = floor(coordinateAbs)
        let minutesNotTruncated = (coordinateAbs - degrees) * 60
        let minutes = floor(minutesNotTruncated)
        let seconds = (minutesNotTruncated - minutes) * 60
        
        return "\(lrint(degrees))°\(lrint(minutes))'\(seconds.roundToDecimal(2))''"
    }
    
    static func converDMS(lat: Double, lon: Double, breakline: Bool) -> String{
        let latitude = toDegreesMinutesAndSecond(coordinate: lat)
        let latitudeCardinal = (lat.sign == .plus) ? "N" : "S"
        
        let longtitude = toDegreesMinutesAndSecond(coordinate: lon)
        let longtitudeCardinal = (lon.sign == .plus) ? "E" : "W"
        
        if breakline {
            return "\(latitude) \(latitudeCardinal)\n\(longtitude) \(longtitudeCardinal)"
            
        }
        return "\(latitude) \(latitudeCardinal) - \(longtitude) \(longtitudeCardinal)"
    }
}
