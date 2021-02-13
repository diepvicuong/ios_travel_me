//
//  BottomSheetViewController.swift
//  travelme
//
//  Created by DiepViCuong on 2/3/21.
//

import UIKit
import GoogleMaps

class BottomSheetViewController: UIViewController {
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var btnAddPost: UIButton!
    @IBOutlet weak var imagePost: CustomImageView!
    
    var fullView: CGFloat {
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        return UIScreen.main.bounds.height - (350 + statusBarHeight)
    }
    
    var partialView: CGFloat {
        // TODO: edit length of partialview here
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        return UIScreen.main.bounds.height - (120 + statusBarHeight)
    }

    private var location =  CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGesture))
        view.addGestureRecognizer(gesture)
        
        initLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            let frame = self?.view.frame
            let yComponent = self?.partialView
            self?.view.frame = CGRect(x: 0, y: yComponent!, width: frame!.width, height: frame!.height)
        }) 
    }

    private func initLayout(){        
        self.viewTop.roundCorners(corners: [.allCorners], radius: 2.0)
        self.btnAddPost.setTitle("Add new trip".localized(), for: .normal)
        self.btnAddPost.addTarget(self, action: #selector(btnAddPostHandle), for: .touchUpInside)
        
        self.btnAddPost.addBorder(borderWidth: 1.0, borderColor: .blue)
        self.btnAddPost.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        self.btnAddPost.layer.cornerRadius = 5.0
        
        self.imagePost.contentMode = .scaleToFill

    }
    
    func reloadData(caption: String, lat: Double, lon: Double, imageUrl: String?){
        self.lbTitle.text = caption
        self.location.latitude = lat
        self.location.longitude = lon
        LocationUtils.getAddressFromLocation(lat: location.latitude, lon: location.longitude, completion: {addressStr in
            self.lbAddress.text = addressStr
        })
        self.btnAddPost.isHidden = true
        self.imagePost.isHidden = false
        if let imageUrl = imageUrl{
            self.imagePost.loadImage(urlString: imageUrl)
        }
    }
    
    func showLocationData(location: CLLocationCoordinate2D){
        self.location = location
        self.lbTitle.text = "Unknown".localized()
        LocationUtils.getAddressFromLocation(lat: location.latitude, lon: location.longitude, completion: {address in
            self.lbAddress.text = address
        })
        self.imagePost.isHidden = true
        self.btnAddPost.isHidden = false
    }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        let y = self.view.frame.minY
        if ( y + translation.y >= fullView) && (y + translation.y <= partialView ) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if recognizer.state == .ended {
            var duration =  velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y )
            
            duration = duration > 1.3 ? 1 : duration
            
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if  velocity.y >= 0 {
                    self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: self.view.frame.height)
                } else {
                    self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: self.view.frame.height)
                }
                
                }, completion: nil)
        }
    }

//    @IBAction func btnCloseTapped(_ sender: UIButton) {
//        UIView.animate(withDuration: 0.3, animations: {
//            let frame = self.view.frame
//            self.view.frame = CGRect(x: 0, y: self.partialView, width: frame.width, height: frame.height)
//        })
//    }
    
    @objc func btnAddPostHandle(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let navVC = mainStoryboard.instantiateViewController(withIdentifier: "AddNavigationVC") as! UINavigationController
        if let vc = navVC.topViewController as? AddVC{
            vc.location = location
        }
        self.present(navVC, animated: true, completion: nil)
    }
    
    func prepareBackgroundView(){
        let blurEffect = UIBlurEffect.init(style: .dark)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        
        view.insertSubview(bluredView, at: 0)
    }
}
