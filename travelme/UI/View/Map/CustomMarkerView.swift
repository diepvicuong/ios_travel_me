//
//  CustomMarkerView.swift
//  travelme
//
//  Created by DiepViCuong on 2/5/21.
//

import Foundation
import UIKit

class CustomMarkerView: UIView{
    
    var imageUrl: String?
    var borderColor: UIColor?
    
    var circleImgView: CustomImageView = {
        let imgView = CustomImageView()
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFit
        imgView.image = UIImage(named: "account")
        imgView.layer.borderColor = UIColor(ciColor: .black).cgColor
        imgView.layer.borderWidth = 4
        return imgView
    }()
    
    var triangleImgView: UIImageView = {
        let triangleImg = UIImageView()
        triangleImg.image = UIImage(named: "markerTriangle")
        triangleImg.tintColor = .black
        return triangleImg
    }()
    
    init(frame: CGRect, imageUrl: String?, borderColor: UIColor?) {
        super.init(frame: frame)
        self.imageUrl = imageUrl
        self.borderColor = borderColor
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    private func sharedInit(){
        addSubview(circleImgView)
        circleImgView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, width: 40, height: 40)
        circleImgView.layer.cornerRadius = 18
        
        addSubview(triangleImgView)
        triangleImgView.anchor(top: circleImgView.bottomAnchor, bottom: bottomAnchor, width: 10/2, height: 10/2)
        triangleImgView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        //load data
        if let imageUrl = self.imageUrl {
            circleImgView.loadImage(urlString: imageUrl)
        }
        if let borderColor = self.borderColor{
            circleImgView.layer.borderColor = borderColor.cgColor
            triangleImgView.tintColor = borderColor
        }
    }
}
