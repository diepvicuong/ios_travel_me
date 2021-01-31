//
//  ViewController.swift
//  travelme
//
//  Created by DiepViCuong on 1/17/21.
//

import UIKit
import MaterialComponents
import SwiftMessages
import GoogleSignIn

class LoginController: AbstractViewController {
    @IBOutlet weak var lbAppName: UILabel!
    @IBOutlet weak var tfEmail: CustomTextField!
    @IBOutlet weak var tfPassword: CustomTextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnGoogleSignin: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    
    var validation = Validation()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initLayout()
        initContent()
        
        //check login with Gmail
        checkLoginGmail()
    }

    private func initLayout(){
        //TextField
        tfEmail.placeholder = "Email".localized()
        tfEmail.sizeToFit()
        tfEmail.clearButtonMode = .whileEditing
        tfEmail.delegate = self
        tfEmail.tag = TextFieldTag.Email.rawValue
        
        tfPassword.placeholder = "Password".localized()
        tfPassword.sizeToFit()
        tfPassword.isSecureTextEntry = true
        tfPassword.delegate = self
        tfPassword.tag = TextFieldTag.Password.rawValue
        
        //Button
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        //Register notification after login-in with Gmail
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLoginGoogle(_:)), name: .signInGoogleCompleted, object: nil)
    
        // Hide keyboard while tap outside
        let hideKBTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        // Using this attribute if dealing with tableviews
        hideKBTap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(hideKBTap)

    }
    
    private func initContent(){
        // Use this if you use navigation bar without navigation controller.
//        navigationController?.navigationBar.topItem?.title = "Login".localized()

        self.title = "Login"
        
        lbAppName.text = "Connected Car".uppercased()
        btnLogin.setTitle("Login".localized(), for: .normal)
        btnSignUp.setTitle("Don't have an account? Sign up".localized(), for: .normal)
        
    }

    private func checkLoginGmail(){
        if let user = GIDSignIn.sharedInstance()?.currentUser{
            // User signed in
            print("Gmail Signed in")
            gotoHome()
        }else{
            // User signed out
            print("Gmail Signed out")
        }
    }
    
    private func validateTextField() -> Bool{
        guard let email = tfEmail.text else { return false}
        if validation.validateEmailId(emailID: email) == false{ return false }
            
        guard let password = tfPassword.text else{ return false}
        if validation.validatePassword(password: password) == false{ return false}
        
        return true
    }
    
    @objc private func userDidLoginGoogle(_ notification: Notification){
        checkLoginGmail()
    }
    
    @objc func hideKeyboard(_ sender: UITapGestureRecognizer){
        tfEmail.resignFirstResponder()
        tfPassword.resignFirstResponder()
    }
    
    @IBAction func SignUpBtnTapped(_ sender: UIButton) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignupViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func LoginBtnTapped(_ sender: UIButton) {
        let successValidation = validateTextField()
        if successValidation == false{
            print("Validation is failed")
            WhisperNotification.showError(errMessage: "\("Login failed".localized())", navController: self.navigationController!)
            return
        }
        
        print("Validation success")
        showLoadingProgress()
        if let email = tfEmail.text, let password = tfPassword.text{
            DispatchQueue.global(qos: .background).async {[weak self] in
                guard self != nil else {return}
                let loginManager = FirebaseAuthManager()
                FirebaseAuthManager.shareInstance.signIn(email: email, password: password){ success in
                    self?.dismissLoadingProgress()
                    DispatchQueue.main.async {[weak self] in
                    guard let strongSelf = self else{return}
                    if success{
                        print("Login success")
                        WhisperNotification.showSucess(successMessage: "Login success".localized(), navController: strongSelf.navigationController!)
                        strongSelf.gotoHome()
                        }
                    else{
                        WhisperNotification.showError(errMessage: "\("Login in failed".localized())", navController: strongSelf.navigationController!)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        let tag = TextFieldTag(rawValue: sender.tag)
        switch tag {
        case .Email:
            guard let email = sender.text else {return}
            if email.isEmpty || validation.validateEmailId(emailID: email){
                tfEmail.showPopTip(isShow: false)
            }else{
                tfEmail.showPopTip(isShow: true, text: "Invalid email")
            }
        case .Password:
            guard let password = sender.text else {return}
            if(password.isEmpty || validation.validatePassword(password: password)){
                tfPassword.showPopTip(isShow: false)
            }else{
                tfPassword.showPopTip(isShow: true, text: "Must be between 6-9 numbers")
            }
        default:
            print("Invalid textfield")
        }
    }
    @IBAction func signInGoogleTapped(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.signIn()
    }
}

extension LoginController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Check if there is any other text-field in the view whose tag is +1 greater than the current text-field on which the return key was pressed. If yes → then move the cursor to that next text-field. If No → Dismiss the keyboard
        if let nextField = self.view.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}


