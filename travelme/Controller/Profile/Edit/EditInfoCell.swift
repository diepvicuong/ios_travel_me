//
//  EditInfoCell.swift
//  travelme
//
//  Created by DiepViCuong on 2/15/21.
//

import UIKit

class EditInfoCell: UITableViewCell {
    var user: User?{
        didSet{
            reloadData()
        }
    }
    
    var viewUserName: UserProfileEditView = {
        let view = UserProfileEditView(title: "Username".localized())
        return view
    }()
    var viewEmail: UserProfileEditView = {
        let view = UserProfileEditView(title: "Email".localized())
        view.tfContent.keyboardType = .emailAddress
        return view
    }()
    var viewPhoneNumber: UserProfileEditView = {
        let view = UserProfileEditView(title: "Phone".localized())
        view.tfContent.keyboardType = .numberPad
        return view
    }()

    static let cellId = "EditInfoCell"
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        sharedInit()
    }
    
    private func sharedInit(){
        let stackView = UIStackView(arrangedSubviews: [viewUserName, viewEmail, viewPhoneNumber])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20)
        
        self.addBorder(edge: [.top], color: .lightGray, thickness: 1.0)
    }
    
    private func reloadData(){
        viewUserName.setContent(user?.username ?? "")
        viewEmail.setContent(user?.email ?? "")
        viewPhoneNumber.setContent(user?.phoneNumber ?? "")
    }
}

class UserProfileEditView: UIView{
    private var title: String = ""
    private var content: String = ""
    
    var lbTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: StaticData.EditProfile.labelInfoSize)
        return label
    }()
    
    var tfContent: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: StaticData.EditProfile.labelInfoSize)
        tf.addBorder(edge: [.bottom], color: StaticData.EditProfile.topBorderColor, thickness: 1.0)
        return tf
    }()
    
    init(title: String? = nil, content: String? = nil ) {
        super.init(frame: .zero)
        if let title = title{
            self.title = title
        }
        if let content = content{
            self.content = content
        }
        sharedInit()
    
        reloadData()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    private func sharedInit(){
        addSubview(lbTitle)
        lbTitle.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, paddingLeft: 10, width: 120)
        
        addSubview(tfContent)
        tfContent.anchor(top: topAnchor, left: lbTitle.rightAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
    
    func setContent(_ content: String){
        self.content = content
        reloadData()
    }
    func reloadData(){
        self.lbTitle.text = self.title
        self.tfContent.text = self.content
    }
}
