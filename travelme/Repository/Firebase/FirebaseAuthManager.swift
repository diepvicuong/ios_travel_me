//
//  FirebaseAuthManager.swift
//  travelme
//
//  Created by DiepViCuong on 1/18/21.
//

import Foundation
import FirebaseAuth
import UIKit
import GoogleSignIn

class FirebaseAuthManager{
    static let shareInstance = FirebaseAuthManager()
    
    func signIn(email: String, password: String, completionBlock: @escaping (_ success: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
               if let error = error, let _ = AuthErrorCode(rawValue: error._code) {
                   completionBlock(false)
               } else {
                   completionBlock(true)
               }
           }
    }
    
    func isHasUser() -> Bool{
        if let user = Auth.auth().currentUser{
            return true
        }else{
            return false
        }
    }
    
    
}

