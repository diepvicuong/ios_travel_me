//
//  AddVC.swift
//  travelme
//
//  Created by DiepViCuong on 1/25/21.
//

import UIKit
import GoogleMaps

class AddVC: AbstractViewController {
    @IBOutlet weak var btnPickImg: UIButton!
    @IBOutlet weak var imgCoverPhoto: UIImageView!

    @IBOutlet weak var tfTripName: CustomTextField!
    @IBOutlet weak var tfLocation: CustomTextField!
    @IBOutlet weak var tfDateStart: CustomTextField!
    @IBOutlet weak var tfDateEnd: CustomTextField!
    
    let datePickerTo: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        return dp
    }()
    
    let datePickerFrom: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        return dp
    }()
    
    var location = CLLocationCoordinate2D(){
        didSet{
            LocationUtils.getAddressFromLocation(lat: location.latitude, lon: location.longitude){[weak self] addressStr in
                self?.tfLocation.text = addressStr
            }
        }
    }
    
    deinit {
        debugPrint("********** AddVC deinit **********")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initLayout()
        initContent()
    }
    

    private func initLayout(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: self, action: #selector(dimissTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done".localized(), style: .plain, target: self, action: #selector(doneTapped))
        
        self.isModalInPresentation = true
        
        // Button
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(pickImageTapped(_:)))
        btnPickImg.setTitle("Pick a cover image".localized(), for: .normal)
        btnPickImg.addGestureRecognizer(tapGesture2)
        btnPickImg.layer.borderWidth = 1
        btnPickImg.layer.borderColor = btnPickImg.currentTitleColor.cgColor
        btnPickImg.layer.cornerRadius = 10.0
        btnPickImg.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    
        // ImageView
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(pickImageTapped(_:)))
        imgCoverPhoto.addGestureRecognizer(tapGesture1)
        imgCoverPhoto.isUserInteractionEnabled = true
        
        // TextField
        tfLocation.isUserInteractionEnabled = false

        tfDateStart.inputView = datePickerFrom
        tfDateStart.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneBtnTfTapped(_:)))
        
        tfDateEnd.inputView = datePickerTo
        tfDateEnd.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneBtnTfTapped(_:)))
        
        tfTripName.backgroundColor = .white
        tfLocation.backgroundColor = .white
        tfDateStart.backgroundColor = .white
        tfDateEnd.backgroundColor = .white
        
        // Hide keyboard while tap outside
        let hideKBTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        // Using this attribute if dealing with tableviews
        hideKBTap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(hideKBTap)
        
    }

    private func initContent(){
        // Navigation title
        navigationItem.title = "Add new".localized()
    
        // Textfield
        tfTripName.placeholder = "Trip name".localized() + "(*)"
        tfLocation.placeholder = "Location".localized()
        tfDateStart.placeholder = "Start Date".localized() + "(*)"
        tfDateEnd.placeholder = "End Date".localized() + "(*)"
    }
    
    @objc func dimissTapped(){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func doneTapped(){
        guard let name = tfTripName.text else {return}
        guard let startStr = tfDateStart.text else {return}
        guard let endStr = tfDateEnd.text else {return}

        if name.isEmpty {
            print("Trip name is nil")
            tfTripName.showPopTip(isShow: true, text: "Trip name must not empty".localized())
            return
        }
        if startStr.isEmpty{
            print("Start date is nil")
            tfDateStart.showPopTip(isShow: true, text: "Start Date must not empty".localized())
            return
        }
        if endStr.isEmpty{
            print("End date is nil")
            tfDateEnd.showPopTip(isShow: true, text: "End Date must not empty".localized())
            return
        }
        
        showLoadingProgress()
    
        var diffDate = Calendar.current.dateComponents([.day], from: datePickerFrom.date, to: datePickerTo.date)
        if startStr == endStr{
            diffDate.day = 1
        }else{
            diffDate.day! += 1
        }
        debugPrint("diffDate:", diffDate)

        PostRepository.sharedInstance.createPost(withImage: imgCoverPhoto?.image, caption: name, lat: location.latitude, lon: location.longitude, startDate: datePickerFrom.date, countDate: diffDate.day ?? 0){[weak self] err in
            guard let strongSelf = self else {return}

            strongSelf.dismissLoadingProgress()
            if let err = err {
                WhisperNotification.showError(errMessage: "Error: \(err)", navController: strongSelf.navigationController!)
                return
            }
            WhisperNotification.showSucess(successMessage: "OK".localized(), navController: strongSelf.navigationController!)
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: Notification.Name.updateProfilePost, object: nil)
        }
        
    }
    
    @objc func pickImageTapped(_ sender: UITapGestureRecognizer){
        print("Choose an image")
        let ac = UIAlertController(title: "Choose Image".localized(), message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Camera".localized(), style: .default, handler: {_ in self.openCamera(childVC: self)}))
        ac.addAction(UIAlertAction(title: "Gallery", style: .default, handler: {_ in self.openGallery(childVC: self)}))
        ac.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    @objc func hideKeyboard(_ sender: UITapGestureRecognizer){
        tfTripName.resignFirstResponder()
        tfLocation.resignFirstResponder()
        tfDateStart.resignFirstResponder()
        tfDateEnd.resignFirstResponder()
    }
    
    @objc func doneBtnTfTapped(_ sender: UITextField){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        if sender == tfDateStart{
            print("datePickerFrom:", datePickerFrom.date)
            tfDateStart.text = formatter.string(from: datePickerFrom.date)
            tfDateStart.showPopTip(isShow: false)
            datePickerTo.minimumDate = datePickerFrom.date
        }else if sender == tfDateEnd{
            print("datePickerTo:", datePickerTo.date)
            tfDateEnd.text = formatter.string(from: datePickerTo.date)
            tfDateEnd.showPopTip(isShow: false)
            datePickerFrom.maximumDate = datePickerTo.date
        }
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        if sender == tfTripName{
            tfTripName.showPopTip(isShow: false)
        }
    }
    
}

extension AddVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        print("image: \(image.imageRendererFormat)" )
        imgCoverPhoto.image = image
        dismiss(animated: true)
    }
}

