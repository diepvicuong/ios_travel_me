//
//  WhisperNotification.swift
//  travelme
//
//  Created by DiepViCuong on 1/21/21.
//

import Foundation
import Whisper

class WhisperNotification {
    static func showError(errMessage: String, navController: UINavigationController){
        let message = Message(title: errMessage, backgroundColor: .red)
        // Show and hide a message after delay
        Whisper.show(whisper: message, to: navController, action: .show)
    }
    
    static func showSucess(successMessage: String, navController: UINavigationController){
        let message = Message(title: successMessage, backgroundColor: .green)
        // Show and hide a message after delay
        Whisper.show(whisper: message, to: navController, action: .show)
    }
    
    static func showAnouncement(title: String,subtitle: String, navController: UINavigationController, completion: (() -> Void)? = nil){
        let announcement = Announcement(title: title, subtitle: subtitle, image: UIImage(named: "notification-alert"), duration: 2, action: completion)
        Whisper.show(shout: announcement, to: navController, completion: completion)
    }
}
