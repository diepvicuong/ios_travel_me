//
//  ViewController.swift
//  travelme
//
//  Created by DiepViCuong on 1/17/21.
//

import UIKit

class LoginController: UIViewController {
    @IBOutlet weak var lbAppName: UILabel!
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnEmail: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationController?.navigationBar.isHidden = true
        
        initLayout()
        initContent()
    }

    private func initLayout(){
        
    }
    
    private func initContent(){
        lbAppName.text = "Travel with me".uppercased()
        btnLogin.setTitle("Login".localized(), for: .normal)
        btnSignUp.setTitle("Don't have an account? Sign up".localized(), for: .normal)
        
        tfUsername.placeholder = "Username".localized()
        tfPassword.placeholder = "Password".localized()
    }

}



