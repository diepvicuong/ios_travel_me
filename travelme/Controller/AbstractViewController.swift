//
//  AbstractViewController.swift
//  travelme
//
//  Created by DiepViCuong on 1/20/21.
//

import UIKit
import NVActivityIndicatorView

class AbstractViewController: UIViewController {
    var activityIndicator: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func showLoadingProgress(){
        let xAxis = self.view.center.x
        let yAxis = self.view.center.y

        let frame = CGRect(x: (xAxis - 50/2), y: (yAxis - 50/2), width: 50, height: 50)
        activityIndicator = NVActivityIndicatorView(frame: frame)
        activityIndicator.type = .ballClipRotate // add your type
        activityIndicator.color = UIColor.black // add your color

        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func dismissLoadingProgress(){
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }

}
