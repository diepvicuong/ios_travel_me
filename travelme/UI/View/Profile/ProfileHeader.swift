//
//  ProfileHeader.swift
//  travelme
//
//  Created by DiepViCuong on 1/31/21.
//

import UIKit
import FirebaseAuth

protocol ProfileHeaderDelegate {
    func editTap()
    func changeToListView()
    func changeToStatisticView()
}

class ProfileHeader: UICollectionViewCell {
    
    var user: User?{
        didSet{
            reloadData()
        }
    }

    var delegate: ProfileHeaderDelegate?
    
    //Using closure to init view
    private let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "account")
        iv.layer.borderColor = StaticData.defaultBorderColor
        iv.layer.borderWidth = StaticData.defaultBorderWidth
        return iv
    }()
    
    private let postsLabel = UserProfileStatsLabel(title: "posts", value: 0)
    private let followersLabel = UserProfileStatsLabel(title: "followers", value: 0)
    private let followingLabel = UserProfileStatsLabel(title: "following", value: 0)
    
    private lazy var followButton: UserProfileFollowButton = {
        let button = UserProfileFollowButton(type: .system)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: StaticData.ProfileHeader.labelFontSize)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return button
    }()
    
    private var usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: StaticData.ProfileHeader.labelFontSize)
        return label
    }()
    
    private lazy var listBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "list"), for: .normal)
        btn.tintColor = .mainBlue
        btn.addTarget(self, action: #selector(listViewHandle), for: .touchUpInside)
        return btn
    }()
    
    private lazy var statisticBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "chart-outline"), for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.2)
        btn.addTarget(self, action: #selector(statisticViewHandle), for: .touchUpInside)
        return btn
    }()
    
    private let padding: CGFloat = 12
    
    static var headerId = "ProfileHeaderId"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    private func sharedInit(){
        debugPrint("sharedInit")
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: padding, paddingLeft: padding, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
                
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: padding, paddingRight: padding)

        layoutUserStatsView()

        addSubview(followButton)
        followButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, right: followingLabel.rightAnchor, paddingTop: 2, height: 34)
        
        layoutBottomToolbar()
    }

    private func layoutUserStatsView() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, right: rightAnchor, paddingTop: padding, paddingLeft: padding, paddingRight: padding, height: 50)
    }
    
    private func layoutBottomToolbar() {
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor(white: 0, alpha: 0.2)

        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor(white: 0, alpha: 0.2)

        let stackView = UIStackView(arrangedSubviews: [listBtn, statisticBtn])
        stackView.distribution = .fillEqually

        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)

        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
        stackView.anchor(top: usernameLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingBottom: 10, height: 44)
    }
    
    func reloadData() {
        guard let user = user else { return }
        if user.username.isEmpty{
            usernameLabel.text = "unknown"
        }else{
            usernameLabel.text = user.username
        }
        reloadFollowButton()
        reloadUserStats()
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImage(urlString: profileImageUrl)
        }
    }
    
    private func reloadFollowButton() {
        debugPrint("Reload follow button")
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        
        if currentLoggedInUserId == userId {
            followButton.type = .edit
            return
        }
        
        let previousButtonType = followButton.type
//        followButton.type = .loading
        
        UserRepository.sharedInstance.isFollowingUser(withUID: userId, completion: { (following) in
            if following {
                self.followButton.type = .unfollow
            } else {
                self.followButton.type = .follow
            }
        }) { (err) in
            self.followButton.type = previousButtonType
        }
        
    }
    
    private func reloadUserStats() {
        debugPrint("Reload user state")
        guard let uid = user?.uid else { return }
        
        PostRepository.sharedInstance.countPosts(withUID: uid){count in
            self.postsLabel.setValue(count)
        }
        

        UserRepository.sharedInstance.numberOfFollowers(withUID: uid) { (count) in
            self.followersLabel.setValue(count)
        }

        UserRepository.sharedInstance.numberOfFollowing(withUID: uid) { (count) in
            self.followingLabel.setValue(count)
        }
    }
    
    @objc private func handleTap(){
        debugPrint("\(followButton.type)-button tap")
        guard let userId = user?.uid else { return }

        if followButton.type == .edit {
            delegate?.editTap()
            return
        }
        let previouBtnType = followButton.type
        followButton.type = .loading
        
        if previouBtnType == .follow{
            UserRepository.sharedInstance.followUser(withUID: userId){ err in
                if err != nil {
                    self.followButton.type = previouBtnType
                    return
                }
                self.reloadFollowButton()
                self.reloadUserStats()
            }
        }else if previouBtnType == .unfollow{
            UserRepository.sharedInstance.unfollowUser(withUID: userId){ err in
                if err != nil {
                    self.followButton.type = previouBtnType
                    return
                }
                self.reloadFollowButton()
                self.reloadUserStats()
            }
        }
        
        NotificationCenter.default.post(name: .updateProfilePost, object: nil)
    }
    @objc private func listViewHandle(){
        debugPrint("listViewHandle")
        listBtn.tintColor = UIColor.mainBlue
        statisticBtn.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.changeToListView()
    }
    @objc private func statisticViewHandle(){
        debugPrint("statisticViewHandle")
        statisticBtn.tintColor = UIColor.mainBlue
        listBtn.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.changeToStatisticView()
    }
}

//MARK: - UserProfileStatsLabel

class UserProfileStatsLabel: UILabel {
    private var title: String = ""
    private var value: String = "0"
    
    init(title: String, value: Int) {
        super.init(frame: .zero)
        self.title = title
        self.value = "\(value)"
        sharedInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        numberOfLines = 0
        textAlignment = .center
        setAttributedText()
    }
    
    func setValue(_ value: Int) {
        self.value = "\(value)"
        setAttributedText()
    }
    
    func setValue(_ value: String){
        self.value = value
        setAttributedText()
    }
    
    func setTitle(_ title: String){
        self.title = title
        setAttributedText()
    }
    
    private func setAttributedText() {
        let attributedText = NSMutableAttributedString(string: "\(value)\n", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: StaticData.ProfileHeader.labelFontSize)])
        attributedText.append(NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: StaticData.ProfileHeader.labelFontSize)]))
        self.attributedText = attributedText
    }
}

//MARK: - FollowButtonType

private enum FollowButtonType {
    case loading, edit, follow, unfollow
}

//MARK: - UserProfileFollowButton

private class UserProfileFollowButton: UIButton {
    
    var type: FollowButtonType = .loading {
        didSet {
            configureButton()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        titleLabel?.font = UIFont.boldSystemFont(ofSize: StaticData.ProfileHeader.labelFontSize)
        layer.borderColor = StaticData.defaultBorderColor
        layer.borderWidth = 1
        layer.cornerRadius = 3
        configureButton()
    }
    
    private func configureButton() {
        switch type {
        case .loading:
            setupLoadingStyle()
        case .edit:
            setupEditStyle()
        case .follow:
            setupFollowStyle()
        case .unfollow:
            setupUnfollowStyle()
        }
    }
    
    private func setupLoadingStyle() {
        setTitle("Loading", for: .normal)
        setTitleColor(.black, for: .normal)
        backgroundColor = .white
        isUserInteractionEnabled = false
    }
    
    private func setupEditStyle() {
        setTitle("Edit Profile", for: .normal)
        setTitleColor(.black, for: .normal)
        backgroundColor = .white
        isUserInteractionEnabled = true
    }
    
    private func setupFollowStyle() {
        setTitle("Follow", for: .normal)
        setTitleColor(.white, for: .normal)
        backgroundColor = UIColor.mainBlue
        layer.borderColor = StaticData.defaultBorderColor
        isUserInteractionEnabled = true
    }
    
    private func setupUnfollowStyle() {
        setTitle("Unfollow", for: .normal)
        setTitleColor(.black, for: .normal)
        backgroundColor = .lightGray
        isUserInteractionEnabled = true
    }
}
