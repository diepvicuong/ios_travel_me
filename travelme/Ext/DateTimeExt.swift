//
//  DateTimeExt.swift
//  travelme
//
//  Created by DiepViCuong on 2/2/21.
//

import Foundation

extension Date{
    var day: String {return Formatter.day.string(from: self)}
    var monthName: String {return Formatter.monthName.string(from: self)}
    var year: String {return Formatter.year.string(from: self)}
    
    func timeAgo() -> String{
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = minute * 60
        let day = hour * 24
        let week = day * 7
        let month = day * 30
        let year = day * 365
        
        if secondsAgo == 0 {
            return "Just now"
        }
        if secondsAgo < minute{
            if secondsAgo == 1{
                return "\(secondsAgo) " + "second ago".localized()
            }else{
                return "\(secondsAgo) " + "seconds ago".localized()
            }
        } else if secondsAgo < hour {
            let minutesAgo: Int = secondsAgo/minute
            if minutesAgo == 1  {
                return "\(minutesAgo) " + "minute ago".localized()
            }else{
                return "\(minutesAgo) " + "minutes ago".localized()
            }
        } else if secondsAgo < day {
            let hoursAgo = secondsAgo/hour
            if hoursAgo == 1{
                return "\(hoursAgo) " + "hour ago".localized()
            }else{
                return "\(hoursAgo) " + "hours ago".localized()
            }
        } else if secondsAgo < week {
            let daysAgo = secondsAgo/day
            if daysAgo == 1{
                return "\(daysAgo) " + "day ago".localized()
            }else{
                return "\(daysAgo) " + "days ago".localized()
            }
        } else if secondsAgo < month {
            let weeksAgo = secondsAgo/week
            if weeksAgo == 1{
                return "\(weeksAgo) " + "week ago".localized()
            }else{
                return "\(weeksAgo) " + "weeks ago".localized()
            }
        } else if secondsAgo < year {
            let monthsAgo = secondsAgo/month
            if monthsAgo == 1{
                return "\(monthsAgo) " + "month ago".localized()
            }else{
                return "\(monthsAgo) " + "months ago".localized()
            }
        } else if secondsAgo == year{
            return "1 " + "year ago".localized()
        }
        return "\(secondsAgo/year) " + "years ago".localized()
    }
    
    func timeAgoShort() -> String{
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = minute * 60
        let day = hour * 24
        let week = day * 7
        let month = day * 30
        let year = day * 365
        
        if secondsAgo == 0 {
            return "Just now"
        }
        if secondsAgo < minute{
            return "\(secondsAgo)s"
        } else if secondsAgo < hour {
            return "\(secondsAgo/minute)min"
        } else if secondsAgo < day {
            return "\(secondsAgo/hour)h"
        } else if secondsAgo < week {
            return "\(secondsAgo/day)d"
        } else if secondsAgo < month {
            return "\(secondsAgo/week)w"
        } else if secondsAgo < year {
            return "\(secondsAgo/month)m"
        } else {
            return "\(secondsAgo/year)y"
        }
    }

}

// <cuongdv25><20210215>: add more formatter
extension Formatter{
    static let day: DateFormatter = {
        let formater = DateFormatter()
        formater.dateFormat = "dd"
        return formater
    }()
    static let monthName: DateFormatter = {
        let formater = DateFormatter()
        formater.dateFormat = "MMM"
        return formater
    }()
    
    static let year: DateFormatter = {
        let formater = DateFormatter()
        formater.dateFormat = "YYYY"
        return formater
    }()
    
    
}
