//
//  MainTabBarController.swift
//  travelme
//
//  Created by DiepViCuong on 1/25/21.
//

import UIKit
import SPPermissions

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
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
    
