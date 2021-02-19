//
//  EditProfileVC.swift
//  travelme
//
//  Created by DiepViCuong on 2/15/21.
//

import UIKit
import FirebaseAuth

protocol EditProfileDelegate {
    func changeImage()
}

class EditProfileVC: AbstractViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var user: User?
    private var imgNewAvatar : UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLayout()
    }

    func initLayout(){
        title = "Edit".localized()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: self, action: #selector(cancelTabHandle))
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done".localized(), style: .plain, target: self, action: #selector(doneTabHandle))
        self.view.backgroundColor = .white
        
        tableView.register(EditImageCell.self, forCellReuseIdentifier: EditImageCell.cellId)
        tableView.register(EditInfoCell.self, forCellReuseIdentifier: EditInfoCell.cellId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
    }
    
    @objc func cancelTabHandle(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doneTabHandle(){
        showLoadingProgress()
        guard let uid = Auth.auth().currentUser?.uid else {
            WhisperNotification.showError(errMessage: "Error".localized(), navController: self.navigationController!)
            dismissLoadingProgress()
            return
        }

        let infoCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? EditInfoCell
        let userNameStr = infoCell?.viewUserName.tfContent.text ?? ""
        let emailStr = infoCell?.viewEmail.tfContent.text
        let phoneStr = infoCell?.viewPhoneNumber.tfContent.text
        
        if userNameStr.isEmpty{
            WhisperNotification.showError(errMessage: "Username must not be empty".localized(), navController: self.navigationController!)
            dismissLoadingProgress()
            return
        }
        if let imgAvatar = self.imgNewAvatar{
            debugPrint("Has new avatar")
            UserRepository.sharedInstance.uploadUserProfileImage(image: imgAvatar){[weak self] urlStr in
                UserRepository.sharedInstance.updateUserInfo(withUID: uid, username: userNameStr, email: emailStr, phoneNumber: phoneStr, profileImageUrl: urlStr){
                    NotificationCenter.default.post(name: Notification.Name.updateProfilePost, object: nil)
                    self?.dismissLoadingProgress()
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }else{
            UserRepository.sharedInstance.updateUserInfo(withUID: uid, username: userNameStr, email: emailStr, phoneNumber: phoneStr){[weak self] in
                NotificationCenter.default.post(name: Notification.Name.updateProfilePost, object: nil)
                self?.dismissLoadingProgress()
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension EditProfileVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let imageCell = tableView.dequeueReusableCell(withIdentifier: EditImageCell.cellId, for: indexPath) as! EditImageCell
        imageCell.delegate = self
        imageCell.user = user
        let infoCell = tableView.dequeueReusableCell(withIdentifier: EditInfoCell.cellId, for: indexPath) as! EditInfoCell
        infoCell.user = user
        
        if indexPath.row == 0 {
            return imageCell
        } else if indexPath.row == 1{
            return infoCell
        } else{
            return infoCell
        }
    }
}

//MARK: - EditProfileDelegate
extension EditProfileVC: EditProfileDelegate{
    func changeImage() {
        debugPrint("EditProfileVC: changeImage")
        let ac = UIAlertController(title: "Choose Image".localized(), message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Camera".localized(), style: .default, handler: {_ in self.openCamera(childVC: self)}))
        ac.addAction(UIAlertAction(title: "Gallery", style: .default, handler: {_ in self.openGallery(childVC: self)}))
        ac.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension EditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        imgNewAvatar = image
        print("image: \(image.imageRendererFormat)" )
        let imageCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? EditImageCell
        imageCell?.imgAvatar.image = image
        dismiss(animated: true)
    }
}

