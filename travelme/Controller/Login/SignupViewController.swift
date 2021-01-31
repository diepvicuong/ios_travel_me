//
//  SignupViewController.swift
//  travelme
//
//  Created by DiepViCuong on 1/18/21.
//

import UIKit
import FirebaseAuth
import MaterialComponents
import Whisper

class SignupViewController: AbstractViewController {
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var tfPhoneNumber: CustomMDCOutlineTextField!
    @IBOutlet weak var tfFullname: CustomMDCOutlineTextField!
    @IBOutlet weak var tfEmail: CustomMDCOutlineTextField!
    @IBOutlet weak var tfPassword: CustomMDCOutlineTextField!
    @IBOutlet weak var btnSignup: UIButton!

    let hintImageView = UIImageView(image: UIImage(named: "visibility"))
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
        tfPhoneNumber.tag = TextFieldTag.PhoneNumber.rawValue
        tfPhoneNumber.delegate = self

        tfFullname.label.text = "Full name".localized()
        tfFullname.sizeToFit()
        tfFullname.clearButtonMode = .whileEditing
        tfFullname.tag = TextFieldTag.FullName.rawValue
        tfFullname.delegate = self
        
        tfEmail.label.text = "Email".localized() + "(*)"
        tfEmail.sizeToFit()
        tfEmail.clearButtonMode = .whileEditing
        tfEmail.tag = TextFieldTag.Email.rawValue
        tfEmail.delegate = self
        
        tfPassword.label.text = "Password".localized() + "(*)"
        tfPassword.sizeToFit()
        tfPassword.isSecureTextEntry = true
        tfPassword.tag = TextFieldTag.Password.rawValue
        tfPassword.rightView = hintImageView
        tfPassword.rightViewMode = .always
        tfPassword.rightView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(passwordHintTapped)))
        tfPassword.rightView?.isUserInteractionEnabled = true
        tfPassword.delegate = self
        
        // Hide keyboard while tap outside
        let hideKBTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        // Using this attribute if dealing with tableviews
        hideKBTap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(hideKBTap)
        
    }
    
    func initContent(){
        title = "Sign Up".localized()
        //Label
        lbDescription.text = "Sign up to enjoy your journey".localized()
    
        //Button
        btnSignup.setTitle("Sign up".localized(), for: .normal)
    }
    func validateTextField() -> Bool{
        guard let email = tfEmail.text else { return false}
        if !validation.validateEmailId(emailID: email){ return false }
            
        guard let password = tfPassword.text else{ return false}
        if !validation.validatePassword(password: password){ return false}
        
        return true
    }
    
    @objc func passwordHintTapped() {
        print("Tapped")
        
        if tfPassword.isSecureTextEntry{
            tfPassword.isSecureTextEntry = false
            hintImageView.image = UIImage(named: "invisibility")
            tfPassword.rightView = hintImageView

        }else{
            tfPassword.isSecureTextEntry = true
            hintImageView.image = UIImage(named: "visibility")
            tfPassword.rightView = hintImageView
            
        }
    }
    @objc func hideKeyboard(_ sender: UITapGestureRecognizer){
        tfEmail.resignFirstResponder()
        tfPassword.resignFirstResponder()
        tfFullname.resignFirstResponder()
        tfPhoneNumber.resignFirstResponder()
    }
    
    @IBAction func SignupTapped(_ sender: UIButton) {
        let successValidation = validateTextField()
        if successValidation == false {
            print("Validation is failed")
            WhisperNotification.showError(errMessage: "\("Validation is failed".localized())", navController: self.navigationController!)
            return
        }
        
        showLoadingProgress()
        if let email = tfEmail.text, let password = tfPassword.text, let fullname = tfFullname.text {
            DispatchQueue.global(qos: .userInitiated).async {[weak self] in
                guard self != nil else {return}
                UserRepository.sharedInstance.createUser(email: email, username: fullname, password: password, image: nil){ [weak self] err in
                    self?.dismissLoadingProgress()
                    DispatchQueue.main.async {[weak self] in
                        guard let strongSelf = self else {return}
                        if let err = err{
                            print("Sign up err:", err)
                            WhisperNotification.showError(errMessage: "\("Sign up failed".localized())", navController: strongSelf.navigationController!)
                        }
                        else{
                            print("Sign up success")
                            WhisperNotification.showSucess(successMessage: "Sign up success".localized(), navController: strongSelf.navigationController!)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        let tag = TextFieldTag(rawValue: sender.tag)
        switch tag {
        case .PhoneNumber:
            guard let phoneNumber = sender.text else {return}
            if(phoneNumber.isEmpty || validation.validatePhoneNumber(phoneNumber: phoneNumber)){
                tfPhoneNumber.showPopTip(isShow: false)
            }else{
                tfPhoneNumber.showPopTip(isShow: true, text: "Must be 10 digits")
            }
        case .FullName:
            guard let fullName = sender.text else {return}
            if fullName.isEmpty || validation.validateName(name: fullName){
                tfFullname.showPopTip(isShow: false)
            }else{
                tfFullname.showPopTip(isShow: true, text: "Length be 18 characters max and 3 characters minimum")
            }
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
                tfPassword.rightView = hintImageView
                tfPassword.rightViewMode = .always
            }else{
                tfPassword.showPopTip(isShow: true, text: "Must be between 6-9 numbers")
            }
        default:
            print("Invalid textfield")
        }
    }
}

enum TextFieldTag: Int {
    case PhoneNumber = 0
    case FullName = 1
    case Email = 2
    case Password = 3
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
