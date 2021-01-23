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
    
    func createUser(email: String, password: String, completionBlock: @escaping (_ success: Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let user = authResult?.user{
                print(user)
                completionBlock(true)
            }else{
                completionBlock(false)
            }
        }
    }
    
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

