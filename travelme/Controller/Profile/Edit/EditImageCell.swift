//
//  EditImageCell.swift
//  travelme
//
//  Created by DiepViCuong on 2/15/21.
//

import UIKit


class EditImageCell: UITableViewCell {
    static let cellId = "EditImageCell"

    var user: User?{
        didSet{
            reloadData()
        }
    }
    
    var delegate: EditProfileDelegate?
    
    lazy var imgAvatar: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "account")
        iv.layer.borderColor = StaticData.defaultBorderColor
        iv.layer.borderWidth = StaticData.defaultBorderWidth
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeAvatarHandle)))
        return iv
    }()
        
    lazy var btnChangeImage: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Change profile picture".localized(), for: .normal)
        btn.setTitleColor(.blue, for: .highlighted)
        btn.addTarget(self, action: #selector(changeAvatarHandle), for: .touchUpInside)
        return btn
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        sharedInit()
    }
    
    private func sharedInit(){
        addSubview(imgAvatar)
        imgAvatar.anchor(top: topAnchor, paddingTop: 10, width: 80, height: 80)
        imgAvatar.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imgAvatar.layer.cornerRadius = 80 / 2

        addSubview(btnChangeImage)
        self.btnChangeImage.anchor(top: imgAvatar.bottomAnchor, bottom: bottomAnchor, paddingBottom: 10)
        btnChangeImage.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        self.addBorder(edge: [.top], color: .lightGray, thickness: 1.0)
    }

    private func reloadData(){
        guard let user = self.user else {return}
        if let photoUrl = user.profileImageUrl{
            imgAvatar.loadImage(urlString: photoUrl)
        }
    }
    
    @objc func changeAvatarHandle(){
        debugPrint("ImageCell: changeAvatarHandle")
        delegate?.changeImage()
    }
}
