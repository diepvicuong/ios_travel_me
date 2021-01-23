//
//  MainTabViewController.swift
//  travelme
//
//  Created by DiepViCuong on 1/22/21.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class MainTabViewController: AbstractViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.topItem?.title = "Home".localized()
        
        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutTapped))
        
        
    }
    
    @objc func logoutTapped(){
        GIDSignIn.sharedInstance()?.signOut()
        do{
            try Auth.auth().signOut()
            gotoLogin()
            
        }catch let error as NSError{
            // %@ - string value and for many more.
        print ("Error signing out from Firebase: %@", error)
        }
    }
}
