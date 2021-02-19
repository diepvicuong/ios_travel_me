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

class HomeViewController: AbstractCollectionVC {
    @IBOutlet weak var collectionView: UICollectionView!
//    var posts = [Post]()
    
    deinit {
        debugPrint("********** HomeVC deinit **********")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createPermission()
        
        initLayout()
        initContent()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
    
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: NSNotification.Name.updateProfilePost, object: nil)

        fetchAllPosts()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.collectionView?.refreshControl?.endRefreshing()
    }
    
    func initLayout(){
        collectionView?.backgroundColor = .white
        
        collectionView?.register(HomePostCollectionViewCell.self, forCellWithReuseIdentifier: HomePostCollectionViewCell.cellId)
        collectionView?.register(ProfileEmptyStateCell.self, forCellWithReuseIdentifier: ProfileEmptyStateCell.cellId)
        collectionView?.delegate = self
        collectionView?.dataSource = self
    }

    func initContent(){
        navigationItem.title = "Home".localized()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutTapped))
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
    
    @objc private func handleRefresh() {
        posts.removeAll()
        fetchAllPosts()
    }
    
    private func fetchAllPosts() {
        showEmptyStateViewIfNeeded()
        fetchPostsForCurrentUser()
        fetchFollowingUserPosts()
        
        //Dismiss the refresh control
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            
            if let isRefreshing = self.collectionView.refreshControl?.isRefreshing{
                //TODO: show snackbar "No internet connection"
                debugPrint("No internet connection")
            }
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    override func showEmptyStateViewIfNeeded(){
        guard let currentUserId = Auth.auth().currentUser?.uid else{
            return
        }
        UserRepository.sharedInstance.numberOfFollowing(withUID: currentUserId) { (numberOfFollowing) in
            UserRepository.sharedInstance.numberOfUserPosts(withUID: currentUserId) { (numberPostofUser) in
                if numberOfFollowing == 0 && numberPostofUser == 0{
                    UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
                        self.collectionView?.backgroundView?.alpha = 1
                    }, completion: nil)
                }else {
                    self.collectionView?.backgroundView?.alpha = 0
                }
            }
        }
    }
    
    private func fetchPostsForCurrentUser(){
        guard let uid = Auth.auth().currentUser?.uid else {return}

        collectionView?.refreshControl?.beginRefreshing()
        PostRepository.sharedInstance.fetchAllPost(withUID: uid, completion: { posts in
            
            self.posts.append(contentsOf: posts)
            self.posts.sort{ $0.createDate.compare($1.createDate) == .orderedDescending}
            for (index, post) in self.posts.enumerated(){
//                debugPrint("post \(index):", post.caption)
                //TODO: add likes, comments
            }
            
            self.collectionView?.reloadData()
            self.collectionView?.refreshControl?.endRefreshing()
        }, withCancel: {err in
            self.collectionView?.refreshControl?.endRefreshing()
        })
    }
    
    private func fetchFollowingUserPosts(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        collectionView?.refreshControl?.beginRefreshing()

        PostRepository.sharedInstance.fetchFollowingUserPost(withUID: uid) { (posts) in
            self.posts.append(contentsOf: posts)
            self.posts.sort{ $0.createDate.compare($1.createDate) == .orderedDescending}
            for (index, post) in self.posts.enumerated(){
//                debugPrint("post \(index):", post.caption)
                //TODO: add likes, comments
            }
            
            self.collectionView?.reloadData()
            self.collectionView?.refreshControl?.endRefreshing()
            
        } withCancel: { (err) in
            self.collectionView?.refreshControl?.endRefreshing()
        }

    }
    
    private func createPermission(){
        let permissions = [SPPermission.camera].filter { !$0.isAuthorized }
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
//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if posts.count == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileEmptyStateCell.cellId, for: indexPath)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomePostCollectionViewCell.cellId, for: indexPath) as! HomePostCollectionViewCell
        cell.post = posts[indexPath.item]
        cell.delegate = self
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if posts.count == 0{
            let emptyStateCellHeight = (view.safeAreaLayoutGuide.layoutFrame.height - 150)
            return CGSize(width: view.frame.width, height: emptyStateCellHeight)
        }else{
            let dummyCell = HomePostCollectionViewCell(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 1000))
            dummyCell.post = posts[indexPath.item]
            dummyCell.layoutIfNeeded()
            
            var height: CGFloat = dummyCell.header.bounds.height
            height += dummyCell.captionLabel.intrinsicContentSize.height
            height += dummyCell.startDateLabel.intrinsicContentSize.height
            height += view.frame.width
            height += 24 + 2*dummyCell.padding
            
            //Spacing cell
            height += 12
            //TODO: edit here
            return CGSize(width: view.frame.width, height: height)
        }
    }
}

