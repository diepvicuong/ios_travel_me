//
//  WelcomeViewController.swift
//  travelme
//
//  Created by DiepViCuong on 1/22/21.
//

import UIKit
import GoogleSignIn
import Firebase

class WelcomeViewController: AbstractViewController {

    deinit {
        debugPrint("********** WelcomeVC deinit **********")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        sleep(2)
        //Register notification after login-in with Gmail
//        NotificationCenter.default.addObserver(self, selector: #selector(userDidLoginGoogle(_:)), name: .signInGoogleCompleted, object: nil)
    
        //check login with Gmail
        checkLoginGmail()

    }
    
    
    private func checkLoginGmail(){
        if let user = GIDSignIn.sharedInstance()?.currentUser{
        
            // User signed in
            print("Gmail Signed in")
            gotoHome()
        }else{
            // Check firebase user
            if FirebaseAuthManager.shareInstance.isHasUser(){
                print("Firebase sign in")
                gotoHome()
            }else{
                print("Signed out")
                gotoLogin()
            }
            
        }
    }
    
//    @objc private func userDidLoginGoogle(_ notification: Notification){
//        checkLoginGmail()
//    }
}
