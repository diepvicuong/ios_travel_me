//
//  SignupViewController.swift
//  travelme
//
//  Created by DiepViCuong on 1/18/21.
//

import UIKit
import FirebaseAuth
import MaterialComponents

class SignupViewController: AbstractViewController {
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var btnEmail: UIButton!
    @IBOutlet weak var tfPhoneNumber: MDCOutlinedTextField!
    @IBOutlet weak var tfFullname: MDCOutlinedTextField!
    @IBOutlet weak var tfUsername: MDCOutlinedTextField!
    @IBOutlet weak var tfPassword: MDCOutlinedTextField!
    @IBOutlet weak var btnSignup: UIButton!
    
    let hintImage = UIImageView(image: UIImage(named: "visibility"))
    var validation = Validation()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initLayout()
        initContent()
        
    }
    
    func initLayout(){
        //Textfield
        tfPhoneNumber.label.text = "Phone number".localized()
        tfPhoneNumber.sizeToFit()
        tfPhoneNumber.clearButtonMode = .whileEditing
        tfPhoneNumber.keyboardType = .numberPad
        tfPhoneNumber.delegate = self
        
        tfFullname.label.text = "Full name".localized()
        tfFullname.sizeToFit()
        tfFullname.clearButtonMode = .whileEditing
        tfFullname.delegate = self
        
        tfUsername.label.text = "Username(*)".localized()
        tfUsername.sizeToFit()
        tfUsername.clearButtonMode = .whileEditing
        tfUsername.delegate = self
        
        tfPassword.label.text = "Password (*)".localized()
        tfPassword.sizeToFit()
        tfPassword.isSecureTextEntry = true
        hintImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(passwordHintTapped)))
        hintImage.isUserInteractionEnabled = true
        tfPassword.trailingView = hintImage
        tfPassword.trailingViewMode = .always
        tfPassword.delegate = self
    }
    
    func initContent(){
        //Label
        lbDescription.text = "Sign up to enjoy your journey".localized()
    
        //Button
        btnEmail.setTitle("Log in with Gmail".localized(), for: .normal)
        btnSignup.setTitle("Sign up".localized(), for: .normal)
    }
    func validateTextField() -> Bool{
        if let username = tfUsername.text, !username.isEmpty {
            if validation.validateName(name: username){
                let email = username + "@gmail.com"
                print("email: \(email)")
            }else{
                print("Invalid username")
                return false
            }
        }else{
            print("Username must not empty")
            return false
        }
        
        if let password = tfPassword.text, !password.isEmpty {
            if validation.validatePassword(password: password){
                print("password: \(password)")
            }else{
                print("Invalid password")
                return false
            }
        }else{
            print("Password must not empty")
            return false
        }
        return true
    }
    
    @objc func passwordHintTapped() {
        print("Tapped")
        
        if tfPassword.isSecureTextEntry{
            tfPassword.isSecureTextEntry = false
            hintImage.image = UIImage(named: "invisibility")
            tfPassword.trailingView = hintImage

        }else{
            tfPassword.isSecureTextEntry = true
            hintImage.image = UIImage(named: "visibility")
            tfPassword.trailingView = hintImage        }
    }
    
    @IBAction func SignupTapped(_ sender: UIButton) {
        let successValidation = validateTextField()
        if successValidation == false {
            print("Validation is failed")
            return
        }
        
        showLoadingProgress()
        if let username = tfUsername.text, let password = tfPassword.text{
            let email = username + "@gmail.com"
            DispatchQueue.global(qos: .userInitiated).async {
                let signUpManager = FirebaseAuthManager()
                signUpManager.createUser(email: email, password: password){ [weak self] success in
                    self?.dismissLoadingProgress()
                    if success{
                    print("Sign up success")
                    DispatchQueue.main.async {
                        let ac = UIAlertController(title: "Success", message: "Sign up success", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(ac, animated: true)
                    }
                }else{
                    print("Sign up failed")
                    DispatchQueue.main.async {
                        let ac = UIAlertController(title: "Error", message: "Sign up error", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(ac, animated: true)
                    }
                }
            }
                
        }
    }
    }
    
}

extension SignupViewController: UITextFieldDelegate{
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
