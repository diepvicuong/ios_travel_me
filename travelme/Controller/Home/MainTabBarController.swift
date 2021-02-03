//
//  MainTabBarController.swift
//  travelme
//
//  Created by DiepViCuong on 1/25/21.
//

import UIKit
import SPPermissions
import FirebaseAuth

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    deinit {
        debugPrint("********** MainTabBarController deinit **********")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
                
        setupControllers()
    }
    
    func setupControllers(){
        guard let uid = Auth.auth().currentUser?.uid else { return }

        guard let vcs = viewControllers else{
            return
        }
        for navController in vcs{
            if let navigationVC = navController as? UINavigationController {
                if let profileVC = navigationVC.topViewController as? ProfileViewController{
                    UserRepository.sharedInstance.fetchUser(withUID: uid) { (user) in
                        profileVC.user = user
                    }
               }
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let navigationVC = viewController as? UINavigationController {
            if navigationVC.topViewController is AddVC{
                if let newVC = tabBarController.storyboard?.instantiateViewController(withIdentifier: "AddNavigationVC") {
                   tabBarController.present(newVC, animated: true)
                   return false
               }
            }
        }        
        return true
    }
    
}
    
