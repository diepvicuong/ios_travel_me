//
//  ProfileStatisticCell.swift
//  travelme
//
//  Created by DiepViCuong on 2/24/21.
//

import UIKit

class ProfileStatisticCell: UICollectionViewCell {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var numOfCountry: UILabel!
    @IBOutlet weak var numOfCity: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initLayout()
    }

    private func initLayout(){
        stackView.distribution = .fillEqually
//        numOfCity.backgroundColor = UIColor(patternImage: UIImage(named: "account")!)
//        numOfCountry.backgroundColor = UIColor(patternImage: UIImage(named: "list")!)
    }
}
