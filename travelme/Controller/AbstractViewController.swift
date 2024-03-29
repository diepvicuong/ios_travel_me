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
        activityIndicator.type = .pacman // add your type
        activityIndicator.color = UIColor.black // add your color

        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
    }
    
    func dismissLoadingProgress(){
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        self.view.isUserInteractionEnabled = true
    }
    
    func changeRootPage(vc: UIViewController) {
//        if let navigationController = self.navigationController{
//            var vcArray = navigationController.viewControllers
//            vcArray.removeAll()
//            vcArray.append(vc)
//            navigationController.setViewControllers(vcArray, animated: false)
//        }
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
    }

}

//MARK: - Change root view
extension AbstractViewController{
    func gotoHome(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
        changeRootPage(vc: vc)
    }
    
    func gotoLogin(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "LoginNavigationController") as! UINavigationController
        changeRootPage(vc: vc)
    }
}

//MARK: - Choose image
extension AbstractViewController{
    func openCamera(childVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate){
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        imagePicker.delegate = childVC
        present(imagePicker, animated: true)
    }
    
    func openGallery(childVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate){
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = childVC
        present(imagePicker, animated: true)
    }
}
