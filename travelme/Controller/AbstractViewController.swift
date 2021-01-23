//
//  AbstractViewController.swift
//  travelme
//
//  Created by DiepViCuong on 1/20/21.
//

import UIKit
import NVActivityIndicatorView

class AbstractViewController: UIViewController {
    var activityIndicator: NVActivityIndicatorView!
    weak var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate = UIApplication.shared.delegate as! AppDelegate
//        initNavBar()
    }
    
    func initNavBar() {
        let btnBack = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(navBackBtnPressed))
        btnBack.setIcon(icon: .ionicons(.iosArrowBack), iconSize: 25, color: .black)
        
        self.navigationItem.leftBarButtonItem = btnBack
        
    }
    
    @objc func navBackBtnPressed(){
//        debugPrint("navBackBtnPressed")
        self.navigationController?.popViewController(animated: false)
    }
    
    func showLoadingProgress(){
        let xAxis = self.view.center.x
        let yAxis = self.view.center.y

        let frame = CGRect(x: (xAxis - 50/2), y: (yAxis - 50/2), width: 50, height: 50)
        activityIndicator = NVActivityIndicatorView(frame: frame)
        activityIndicator.type = .ballClipRotate // add your type
        activityIndicator.color = UIColor.black // add your color

        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func dismissLoadingProgress(){
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    func changeRootPage(vc: UIViewController) {
        if let navigationController = self.navigationController{
            var vcArray = navigationController.viewControllers
            vcArray.removeAll()
            vcArray.append(vc)
            navigationController.setViewControllers(vcArray, animated: false)
        }
    }

}

// Change root view
extension AbstractViewController{
    func gotoHome(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "MainTabViewController") as! MainTabViewController
        changeRootPage(vc: vc)
    }
    
    func gotoLogin(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginController
        changeRootPage(vc: vc)
    }
}
