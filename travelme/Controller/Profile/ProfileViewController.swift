//
//  ProfileViewController.swift
//  travelme
//
//  Created by DiepViCuong on 1/31/21.
//

import UIKit
import FirebaseAuth

class ProfileViewController: AbstractCollectionVC {
    @IBOutlet weak var collectionView: UICollectionView?
    
//    var posts = [Post]()

    private var header: ProfileHeader?
    private let headerHeight: CGFloat = 200
    
    private var isStatistic = false
    
    var user: User?{
        didSet{
            debugPrint("Configure user: ", user)
            configureUser()
        }
    }
    
    deinit {
        debugPrint("********** ProfileVC deinit **********")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        debugPrint("init Profile VC")
        
        initLayout()
        initContent()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
    
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: NSNotification.Name.updateProfilePost, object: nil)

    }
    
    func initLayout(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "setting"), style: .done, target: self, action: #selector(rightBarBtnTapped))
        
        collectionView?.backgroundColor = .white
        collectionView?.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeader.headerId)
        collectionView?.register(HomePostCollectionViewCell.self, forCellWithReuseIdentifier: HomePostCollectionViewCell.cellId)
        collectionView?.register(ProfileEmptyStateCell.self, forCellWithReuseIdentifier: ProfileEmptyStateCell.cellId)
        collectionView?.register(UINib(nibName: "ProfileStatisticCell", bundle: nil), forCellWithReuseIdentifier: "ProfileStatisticCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
    }

    func initContent(){
        navigationItem.title = "Profile".localized()
    }
    
    private func configureUser() {
        guard let user = user else { return }
        
//        if user.uid == Auth.auth().currentUser?.uid {
//            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleSettings))
//        } else {
//            let optionsButton = UIBarButtonItem(title: "•••", style: .plain, target: nil, action: nil)
//            optionsButton.tintColor = .black
//            navigationItem.rightBarButtonItem = optionsButton
//        }
        
        navigationItem.title = user.username
        header?.user = user
        
        handleRefresh()
    }
    
    @objc func rightBarBtnTapped(){
        debugPrint("Setting tapped")
    }
    
    @objc func handleRefresh(){
        debugPrint("handleRefresh")
        guard let uid = user?.uid else {return}
        
        posts.removeAll()
        
        PostRepository.sharedInstance.fetchAllPost(withUID: uid, completion: { posts in
            
            self.posts = posts
            //TODO: sort by date
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
        UserRepository.sharedInstance.fetchUser(withUID: uid){[weak self] user in
            guard let strongSelf = self else {return}
            strongSelf.header?.user = user
        }
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if posts.count == 0 || isStatistic{
            return 1
        }

        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if posts.count == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileEmptyStateCell.cellId, for: indexPath)
            return cell
        }
        if isStatistic{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileStatisticCell", for: indexPath) as! ProfileStatisticCell
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomePostCollectionViewCell.cellId, for: indexPath) as! HomePostCollectionViewCell
        cell.post = posts[indexPath.item]
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if header == nil {
            header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeader.headerId, for: indexPath) as? ProfileHeader
            
            //TODO: edit here
            header?.user = user
            header?.delegate = self
        }
        
        return header!
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if posts.count == 0{
            let emptyStateCellHeight = (view.safeAreaLayoutGuide.layoutFrame.height - headerHeight)
            return CGSize(width: view.frame.width, height: emptyStateCellHeight)
        }else{
            if isStatistic{
                let statisticCell = ProfileStatisticCell(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 1000))
                statisticCell.layoutIfNeeded()
                let height =  statisticCell.bounds.height
                return CGSize(width: view.frame.width, height: height)
            }
            
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: headerHeight)
    }
}

extension ProfileViewController: ProfileHeaderDelegate{
    func changeToListView() {
        isStatistic = false
        collectionView?.reloadData()
    }
    
    func changeToStatisticView() {
        isStatistic = true
        collectionView?.reloadData()
    }
    
    func editTap() {
        debugPrint("edit tapped")
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "EditProfileVC2") as! EditProfileVC
        vc.user = self.header?.user
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true)
    }
}
