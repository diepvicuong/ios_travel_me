//
//  HomePostCellHeader.swift
//  travelme
//
//  Created by DiepViCuong on 2/1/21.
//

import UIKit
import FirebaseAuth

protocol HomePostCellHeaderDelegate {
    func didTapUser()
    func dipTapOption()
}

class HomePostCellHeader: UIView {

    var user: User?{
        didSet{
            configureUser()
        }
    }
    var createDate: Date?{
        didSet{
            self.timeAgoLabel.text = createDate?.timeAgo()
        }
    }
    var delegate: HomePostCellHeaderDelegate?
    private let padding: CGFloat = 12
    
    private let userProfileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "account")
        imageView.layer.borderColor = StaticData.defaultBorderColor
        imageView.layer.borderWidth = StaticData.defaultBorderWidth
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let usernameButton: UIButton = {
       let btn = UIButton()
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.contentHorizontalAlignment = .left
        btn.addTarget(self, action: #selector(handleUserTap), for: .touchUpInside)
        return btn
    }()
    
    private let timeAgoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.italicSystemFont(ofSize: 10)
        return label
    }()
    
    private let optionButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("•••", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        btn.addTarget(self, action: #selector(handleOptionTap), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    private func sharedInit(){
        addSubview(userProfileImageView)
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, paddingLeft: padding, width: 30, height: 30)
        userProfileImageView.layer.cornerRadius = 30/2
        userProfileImageView.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(handleUserTap)))
        
//        addSubview(usernameButton)
//        usernameButton.anchor(top: topAnchor, left: userProfileImageView.rightAnchor, bottom: bottomAnchor, paddingLeft: padding)

        setUserInfoLayout()
        
        addSubview(optionButton)
        optionButton.anchor(top: topAnchor, bottom: bottomAnchor, right: rightAnchor, paddingRight: padding, width: 40)
    }
    
    private func setUserInfoLayout(){
        let stackview = UIStackView(arrangedSubviews: [usernameButton, timeAgoLabel])
        stackview.axis = .vertical
        
        addSubview(stackview)
        stackview.anchor(top: topAnchor, left: userProfileImageView.rightAnchor, bottom: bottomAnchor, paddingLeft: padding)
    }
    
    private func configureUser(){
        guard let user = user else {return}
        
        usernameButton.setTitle(user.username, for: .normal)
        if let profileUri = user.profileImageUrl{
            userProfileImageView.loadImage(urlString: profileUri)
        }else{
            userProfileImageView.image = UIImage(named: "account")
        }
    }
    
    @objc func handleUserTap(){
        delegate?.didTapUser()
    }
    
    @objc func handleOptionTap(){
        delegate?.dipTapOption()
    }
}
