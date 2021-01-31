//
//  MainTabViewController.swift
//  travelme
//
//  Created by DiepViCuong on 1/22/21.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import SPPermissions

class HomeViewController: AbstractViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Home".localized()
        navigationController?.tabBarItem.badgeValue = "C"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutTapped))
    
        createPermission()
        
        WhisperNotification.showAnouncement(title: "Welcome", subtitle: "Hello user \(Auth.auth().currentUser?.uid)", navController: self.navigationController!)
    }
    
    @objc func logoutTapped(){
        GIDSignIn.sharedInstance()?.signOut()
        do{
            try Auth.auth().signOut()
            gotoLogin()
            
        }catch let error as NSError{
            // %@ - string value and for many more.
        print ("Error signing out from Firebase: %@", error)
        }
    }
    
    private func createPermission(){
        let permissions = [SPPermission.camera, SPPermission.locationWhenInUse].filter { !$0.isAuthorized }
        if permissions.isEmpty{
            debugPrint("All permission are allowed")
            return
        }
        
        let controller = SPPermissions.dialog(permissions)

        // Ovveride texts in controller
        controller.titleText = "Permission request".localized()
        controller.headerText = "Please allow all permissions".localized()

        // Set `DataSource` or `Delegate` if need.
        // By default using project texts and icons.
        controller.dataSource = self
        controller.delegate = self

        // Always use this method for present
        controller.present(on: self)
    }
}

extension HomeViewController: SPPermissionsDelegate, SPPermissionsDataSource{
    func configure(_ cell: SPPermissionTableViewCell, for permission: SPPermission) -> SPPermissionTableViewCell {
        // Titles
        let title: String
        switch permission {
        case .camera:
            title = "Camera".localized()
        case .locationWhenInUse:
            title = "Location".localized()
        default:
            title = permission.name
        }
        cell.permissionTitleLabel.text = title
        cell.permissionDescriptionLabel.text = "Allow app for use \(title)"
        cell.button.allowTitle = "Allow hehe".localized()
        cell.button.allowedTitle = "Allowed".localized()

        return cell
    }
    
    func deniedData(for permission: SPPermission) -> SPPermissionDeniedAlertData? {
        if permission == .camera || permission == .locationWhenInUse {
            let data = SPPermissionDeniedAlertData()
            data.alertOpenSettingsDeniedPermissionTitle = "\(permission.name) permission denied"
            data.alertOpenSettingsDeniedPermissionDescription = "Please, go to Settings and allow permission."
            data.alertOpenSettingsDeniedPermissionButtonTitle = "Settings"
            data.alertOpenSettingsDeniedPermissionCancelTitle = "Cancel"
            return data
        } else {
            // If returned nil, alert will not show.
            return nil
        }
    }
    
}
