//
//  MapViewController.swift
//  travelme
//
//  Created by DiepViCuong on 1/24/21.
//

import UIKit
import GoogleMaps
import GoogleMapsUtils
import SPPermissions
import FirebaseAuth

class MapViewController: AbstractViewController {
    @IBOutlet weak var myMapView: GMSMapView!
    @IBOutlet weak var btnMapType: UISegmentedControl!
    @IBOutlet weak var btnCurrentLoc: UIButton!
    //BOTTOM SHEET
    let bottomSheetVC = BottomSheetViewController()

    //CLUSTER MAP
    private var clusterManager: GMUClusterManager!
    private var iconGenerator: GMUDefaultClusterIconGenerator!
    private var algorithm: GMUNonHierarchicalDistanceBasedAlgorithm!
    private var renderer: GMUDefaultClusterRenderer!
    
    private var postItemDic = [String: PostClusterItem]()
    private let zoomAllInsect : CGFloat = 60

    let customMarkerWidth: Int = 40
    let customMarkerHeight: Int = 40
    
    var posts: [Post] = [Post](){
        didSet{
//            drawMapPost()
        }
    }
    
    private var targetCircle : UIView? = {
        var circleView = UIView()
        circleView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 40, height: 40))
        circleView.layer.cornerRadius = 18
        circleView.backgroundColor = UIColor(white: 0, alpha: 0.1)
        return circleView
    }()
    
    //TARGET SINGLE DEVICE
    var isTargetSinglePost = false
    private var currentSelectedId : String?
    private var currentSelectedPostItem : PostOnMap?
    
    //LOCATION
    private var locationManager = CLLocationManager()
    private var myCurrentLocation : CLLocation?
    
    //Marker
    private var only1Marker = GMSMarker()
    
    deinit {
        debugPrint("********** MapVC deinit **********")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initContent()
        initMap()
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefreshPost), name: NSNotification.Name.updateProfilePost, object: nil)
        
        handleRefreshPost()
        
        addBottomSheetView()

        //Move camera to HCM city
        let camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: 10.7882937, longitude: 106.6946765), zoom: 8, bearing: 0, viewingAngle: 0)
        self.myMapView.camera = camera
    }
    
    
    func initContent(){
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // called normal.png and selected.png.
        let normalImage = UIImage(named: "my-location-selected")
        let selectedImage = UIImage(named: "my-location")
        btnCurrentLoc.setImage(normalImage, for: .normal)
        btnCurrentLoc.setImage(selectedImage, for: .selected)
    }
    
    func initMap(){
        self.myMapView.settings.rotateGestures = false
        
        self.myMapView.settings.compassButton = true
        self.myMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.myMapView.isMyLocationEnabled = true
        
        //map cluster
        //https://stackoverflow.com/questions/40837717/custom-marker-using-gmuclustermanager/53928566#53928566
        //http://studyswift.blogspot.com/2016/07/marker-clustering-with-googles-utility.html
        
        let buckets: [NSNumber] = [50, 500 , 5000, 20000 , 50000]
        var clusterImages: [UIImage] = []
        for id in 1...buckets.count{
            clusterImages.append(UIImage(named: "cluster\(id)")!)
        }
        self.iconGenerator = GMUDefaultClusterIconGenerator(buckets: buckets, backgroundImages: clusterImages)
        self.algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        self.renderer = GMUDefaultClusterRenderer(mapView: self.myMapView, clusterIconGenerator: self.iconGenerator)
        self.renderer.delegate = self
        self.clusterManager = GMUClusterManager(map: self.myMapView, algorithm: self.algorithm, renderer: self.renderer)
        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
        self.clusterManager.setDelegate(self, mapDelegate: self)

        //Location Manager code to fetch current location
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
    }
    
    func addBottomSheetView(scrollable: Bool? = true) {
        self.addChild(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParent: self)

        let height = view.frame.height
        let width  = view.frame.width
        bottomSheetVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
        bottomSheetVC.view.roundCorners(corners: [.topLeft, .topRight], radius: 20.0)
    }
    
    @objc func handleRefreshPost(){
        guard let currentUserId = Auth.auth().currentUser?.uid else {return}
        self.posts.removeAll()
        self.postItemDic.removeAll()

        PostRepository.sharedInstance.fetchFollowingUserPost(withUID: currentUserId, completion: {[weak self]
            posts in
            guard let strongSelf = self else {return}
            strongSelf.posts.append(contentsOf: posts)
            strongSelf.drawMapPost()
        }, withCancel: {err in
            debugPrint("Failed to handleRefreshPost:", err)
            }
        )
        
        PostRepository.sharedInstance.fetchAllPost(withUID: currentUserId) {[weak self] (posts) in
            guard let strongSelf = self else {return}
            strongSelf.posts.append(contentsOf: posts)
            strongSelf.drawMapPost()
        } withCancel: { (err) in
            debugPrint("Failed to handleRefreshPost:", err)

        }

    }
    
    @IBAction func changeMapTypeHandle(_ sender: UISegmentedControl) {
        switch btnMapType.selectedSegmentIndex {
        case 0:
            self.myMapView.mapType = .normal
            break
        case 1:
            self.myMapView.mapType = .satellite
            break
        default:
            debugPrint("Invalid selected segment index")
            break
        }
    }
    
    @IBAction func btnCurrentLocHandle(_ sender: UIButton) {
        debugPrint("btnCurrentLocHandle")

        if !SPPermission.locationWhenInUse.isAuthorized{
            let ac = UIAlertController(title: "Alert".localized(), message: "Location permission is not allowed", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(ac, animated: true)
            debugPrint("Location permission is not allowed")

            return
        }
        if let myLocation = myCurrentLocation {
            let camera = GMSCameraPosition(target: myLocation.coordinate, zoom: 14, bearing: 0, viewingAngle: 0)
            self.myMapView.camera = camera
        }
    }
}
//MARK: SINGLE TARGET DEVICE
extension MapViewController{
    func onMarkerSelected(postOnMap: PostOnMap){
        if let postClusterItem = self.postItemDic[postOnMap.id]{
            let camera = GMSCameraPosition(target: postClusterItem.position, zoom: 14, bearing: 0, viewingAngle: 0)
            self.myMapView.camera = camera
            
            onMarkerSelected(postClusterItem: postClusterItem)
        }
    }
    
    func onMarkerSelected(postClusterItem: PostClusterItem){
        self.isTargetSinglePost = true
        self.currentSelectedId = postClusterItem.postOnMap.id
        self.currentSelectedPostItem = postClusterItem.postOnMap
        
        reloadBottomSheet(postOnMap: postClusterItem.postOnMap, position: postClusterItem.position)
    }
    
    func reloadBottomSheet(postOnMap: PostOnMap, position: CLLocationCoordinate2D){
        self.myMapView.animate(toLocation: position)
        let point = myMapView.projection.point(for: position)
        let newpoint = myMapView.projection.coordinate(for: point)
        let camera = GMSCameraUpdate.setTarget(newpoint)
        myMapView.animate(with: camera)
        
        //Debug
        debugPrint(postOnMap)
        bottomSheetVC.reloadData(caption: postOnMap.caption, lat: postOnMap.lat, lon: postOnMap.lon, imageUrl: postOnMap.imageUrl)
//        showAnimatingCircle(postOnMap: postOnMap, position: position)
    }
    
    func showAnimatingCircle(postOnMap : PostOnMap, position: CLLocationCoordinate2D) {
        self.targetCircle?.center = myMapView.projection.point(for: position)
        myMapView.addSubview(targetCircle!)
        
        self.view.layer.removeAllAnimations()
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.repeat], animations: { [weak self] in
            guard let strongSelf = self else{return}
            let scale = CGAffineTransform(scaleX: 2.0, y: 2.0)
            strongSelf.targetCircle?.transform = scale
        }) { (finished) in}
    }
}

extension MapViewController{
    @objc func drawMapPost(isBound: Bool = false){
        debugPrint("draw all posts")

        currentSelectedPostItem = nil
        for post in self.posts {
            let postOnMap = PostOnMap(post: post)
            let postLocation = CLLocationCoordinate2D(latitude: postOnMap.lat, longitude: postOnMap.lon)
            
            if let currentSelectedId = self.currentSelectedId , self.isTargetSinglePost && currentSelectedId == postOnMap.id{
                self.currentSelectedPostItem = postOnMap
            }
            
            let postClusterItem = PostClusterItem(position: postLocation, name: postOnMap.caption , postOnMap: postOnMap)

            self.postItemDic[postOnMap.id] = postClusterItem
        }
        
        var shouldBound = isBound
        //dang zoom toi thiet bi nhung thiet bi da bi xoa
        if self.isTargetSinglePost && self.currentSelectedPostItem == nil {
//            self.shutdownSingleTargetDeviceMode();
            shouldBound = true;
        }
        
        clusterManager.clearItems()
        clusterManager.add(Array(self.postItemDic.values))
        clusterManager.cluster()

        if let currentSelectedPostItem = self.currentSelectedPostItem,
            self.isTargetSinglePost {
            onMarkerSelected(postOnMap: currentSelectedPostItem)
        }
        else if shouldBound{
            self.zoomAllPosts()
        }
    }
}

//MARK: ALL TARGET POSTS
extension MapViewController{
    func zoomAllPosts(){
        var postItemBounds = GMSCoordinateBounds()
        for postItem in self.postItemDic.values{
            postItemBounds = postItemBounds.includingCoordinate(postItem.position)
        }
        
        self.myMapView.animate(with: GMSCameraUpdate.fit(postItemBounds, with: UIEdgeInsets(top: zoomAllInsect, left: zoomAllInsect, bottom: zoomAllInsect, right: zoomAllInsect)))
    }
}

//MARK: IMPLEMENT GMSMapViewDelegate , GMUClusterManagerDelegate , GMUClusterRendererDelegate
extension MapViewController: GMSMapViewDelegate, GMUClusterRendererDelegate, GMUClusterManagerDelegate{
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
//        debugPrint("mapView didchange position")
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        debugPrint("mapView didTap marker: \(marker.userData)")
        if let postClusterItem = marker.userData as? PostClusterItem{
            onMarkerSelected(postClusterItem: postClusterItem)
            only1Marker.map = nil
        }
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
//        debugPrint("mapView didTapAt coordinate: \(coordinate)")
        bottomSheetVC.showLocationData(location: coordinate)
        only1Marker.map = self.myMapView
        only1Marker.position = coordinate
    }
    
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        debugPrint("render marker: \(marker.userData)")
        if let postClusterItem = marker.userData as? PostClusterItem {
            // TODO: edit to custom marker
//            marker.icon = UIImage(named: "location")
            let iconView = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: customMarkerWidth, height: customMarkerHeight), imageUrl: postClusterItem.postOnMap.user.profileImageUrl, borderColor: nil)
            marker.iconView = iconView
        }else if let cluster = marker.userData as? GMUCluster{
            //render cluster
            if self.isTargetSinglePost{
                let isClusterContainSelectedPost = cluster.items.contains { (clusterItem) -> Bool in
                    if let postClusterItem = clusterItem as? PostClusterItem{
                        return postClusterItem.postOnMap.id == self.currentSelectedId
                    }
                    return false
                }
                
                if isClusterContainSelectedPost{
//                    shutdownSingleTargetDeviceMode()
                }
            }
        }
        //TODO case if marker is cluster
    }
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        debugPrint("did tap cluster")
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position, zoom: self.myMapView.camera.zoom + 5)
        let update = GMSCameraUpdate.setCamera(newCamera)
        self.myMapView.moveCamera(update)
        return false
    }
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap clusterItem: GMUClusterItem) -> Bool {
        debugPrint("did tap clusterItem")
        return false
    }
}

//MARK: - IMPLEMENT CLLocationManagerDelegate
extension MapViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //verify the user has granted you permission while the app is in use.
        guard status == .authorizedWhenInUse else {
            return
        }
        
        //Once permissions have been established, ask the location manager for updates on the user’s location
        self.locationManager.startUpdatingLocation()
        self.myMapView.isMyLocationEnabled = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        self.myCurrentLocation = location
    }
}
