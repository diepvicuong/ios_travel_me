//
//  HomePostCellCollectionViewCell.swift
//  travelme
//
//  Created by DiepViCuong on 2/1/21.
//

import UIKit

protocol HomePostCellDelegate {
    func didTapComment(post: Post)
    func didTapUser(user: User)
    func didTapOptions(post: Post)
    func didLike(for cell: HomePostCollectionViewCell)
}

class HomePostCollectionViewCell: UICollectionViewCell{
    
    var post: Post? {
        didSet{
            configurePost()
        }
    }
    
    var delegate: HomePostCellDelegate?
    
    static var cellId = "HomePostCellId"
    let header = HomePostCellHeader()
    let padding: CGFloat = 12
    
    let captionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .left
        label.numberOfLines = 1
        
        return label
    }()
    
    let startDateLabel: UserProfileStatsLabel = {
       let label = UserProfileStatsLabel(title: "Jan", value: 2021)
        label.textAlignment = .left
        return label
    }()
    let numOfDayLabel: UserProfileStatsLabel = {
        let label = UserProfileStatsLabel(title: "days", value: 0)
        label.textAlignment = .left
       return label
    }()
    let numOfPhotoLabel: UserProfileStatsLabel = {
        let label = UserProfileStatsLabel(title: "photos", value: 0)
        label.textAlignment = .left
        return label
    }()
    private let photoImageView: CustomImageView = {
        let photo = CustomImageView()
        photo.contentMode = .scaleAspectFill
        photo.clipsToBounds = true
        photo.backgroundColor = UIColor(white: 0.95, alpha: 1)
        return photo
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "like-unselected")!.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    private lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "comment")!.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    private let likeCounter: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .black
        return label
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
        addSubview(header)
        header.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, width: self.frame.width)
        header.delegate = self
        
        addSubview(captionLabel)
        captionLabel.anchor(top: header.bottomAnchor, left: leftAnchor, right: rightAnchor,paddingTop: 5, paddingLeft: padding, paddingRight: padding)

        layoutPostStateView()

        addSubview(photoImageView)
        photoImageView.anchor(top: startDateLabel.bottomAnchor, left: leftAnchor , right: rightAnchor)
        photoImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true

        setupActionButtons()

        addSubview(likeCounter)
        likeCounter.anchor(top: likeButton.bottomAnchor, left: leftAnchor, paddingTop: padding, paddingLeft: padding)
    }
    
    private func layoutPostStateView(){
        let stackView = UIStackView(arrangedSubviews: [startDateLabel, numOfDayLabel, numOfPhotoLabel])
        stackView.distribution = .fillEqually
        stackView.spacing = 20.0
        addSubview(stackView)
        stackView.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, paddingTop: padding, paddingLeft:  padding, height: 40)
    }
    
    private func setupActionButtons() {
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton])
        stackView.distribution = .fillEqually
        stackView.alignment = .top
        stackView.spacing = 16
        addSubview(stackView)
        stackView.anchor(top: photoImageView.bottomAnchor, left: leftAnchor, paddingTop: padding, paddingLeft: padding)
    }
    
    private func configurePost(){
        guard let post = post else {return}
        header.user = post.user
        header.createDate = post.createDate
        captionLabel.text = post.caption
        configPostState()
        photoImageView.loadImage(urlString: post.imageUrl)
//        likeButton.setImage(post.likedByCurrentUser == true ? #imageLiteral(resourceName: "like_selected").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
//        setLikes(to: post.likes)
    }
    
    private func configPostState(){
        guard let post = post else {return}
        debugPrint("startDate:", post.startDate)
//        let day = Calendar.current.component(.day, from: post.startDate)
//        let month = Calendar.current.component(.month, from: post.startDate)
//        let year = Calendar.current.component(.year, from: post.startDate)

        let dayStr = post.startDate.day
        let monthStr = post.startDate.monthName
        let yearStr = post.startDate.year
        startDateLabel.setTitle("\(monthStr),\(yearStr)")
        startDateLabel.setValue(dayStr)
        debugPrint("Count:", post.countDate)
        numOfDayLabel.setValue(post.countDate)

    }
    
    private func setLikes(to value: Int) {
        if value <= 0 {
            likeCounter.text = ""
        } else if value == 1 {
            likeCounter.text = "1 like"
        } else {
            likeCounter.text = "\(value) likes"
        }
    }
    
    @objc func handleLike(){
        //TODO
    }
    
    @objc func handleComment(){
        //TODO
    }
}

extension HomePostCollectionViewCell: HomePostCellHeaderDelegate{
    func didTapUser() {
        guard let user = post?.user else { return }
        delegate?.didTapUser(user: user)
    }
    
    func dipTapOption() {
        guard let post = post else { return }
        delegate?.didTapOptions(post: post)
    }
    
    
}
