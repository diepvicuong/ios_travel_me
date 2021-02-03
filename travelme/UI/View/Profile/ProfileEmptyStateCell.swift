//
//  ProfileEmptyStateCell.swift
//  travelme
//
//  Created by DiepViCuong on 2/1/21.
//

import UIKit

class ProfileEmptyStateCell: UICollectionViewCell {
    
    private let emptyLable: UILabel = {
       let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Empty".localized()
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()
    
    static let cellId = "ProfileEmptyStateCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    private func sharedInit(){
        addSubview(emptyLable)
        emptyLable.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
}
