//
//  ViewController.swift
//  ingine
//
//  Created by McNels on 5/25/19.
//  Copyright © 2019 ingine. All rights reserved.
//

import ARKit
import SceneKit
import UIKit
import Firebase
import SafariServices

class ViewController: PortraitViewController, ARSCNViewDelegate {
    var db: Firestore!
    var arAssets = [ARImageAsset]()
    let arQueue = DispatchQueue(label: "ArrrayQueue")
    let maxNumImages = 200
    
    var currentImgIndex = 0
    var downloadCount = 0
    var isReloading = false
    
    var arImageCycleTimer : Timer?
    
    // Scene initializations
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var userButton: UIButton?
    let cameraButton = UIButton.init()
    
    /// The view controller that displays the status and "restart experience" UI.
    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    
    /// A serial queue for thread safety when modifying the SceneKit node graph.
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    let downloadQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".serialDownloadQueue")
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        // setup login/signup/profile page access
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        DispatchQueue.main.async {
            // Scene setup
            self.sceneView.delegate = self
            self.sceneView.session.delegate = self
            
            // Camera button setup
            self.cameraButton.frame = CGRect.init(x: 0, y: 0, width: 80, height: 80)
            self.cameraButton.setImage(UIImage.init(named: "camera"), for: .normal)
            self.cameraButton.center = CGPoint.init(x: self.view.center.x, y: self.view.frame.size.height - 60)
            self.cameraButton.addTarget(self, action: #selector(self.takePhotoAction), for: .touchUpInside)
            self.sceneView.addSubview(self.cameraButton)
            self.sceneView.autoenablesDefaultLighting = true
            
            // Gestures setup
            self.view.addGestureRecognizer(leftSwipe)
            self.view.addGestureRecognizer(rightSwipe)
            
            let config = ARImageTrackingConfiguration()
            self.session.run(config, options: [.resetTracking, .removeExistingAnchors])
            
            self.openTutorialPage(isForFirstTimers: true)
        }
        
//        resetTracking()
        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
        
    }
    
    @objc func refreshConfig()
    {
        //todo jt need to improve this
        //self.restartExperience()
    }

    @IBAction func goToProfileSetting() {
        if isLoggedIn() {
            // send to profile view
            performSegue(withIdentifier: "toProfile", sender: nil)
        } else {
            let login = AccountViewController()
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = login
        }
    }
    
    // handle swipe gestures from home screen
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            print("Swipe Left")
            goToProfileSetting()
        }
        
        if (sender.direction == .right) {
            print("Swipe Right")
            // send to settings view
        }
    }
    
    
    @IBAction func modalDismissed(segue: UIStoryboardSegue) {
      // You can use segue.source to retrieve the VC
      // being dismissed to collect any data which needs
      // to be processed
    }
    
    func isLoggedIn() -> Bool {
        var status : Bool
        if Auth.auth().currentUser?.uid != nil {
            print("not logged in by email")
            status = true
        } else {
            status = false
        }
        
        return status
    }

    // take photo when user clicks camera button
    @objc func takePhotoAction(){
        print("camera button pressed")
        
       // DispatchQueue.main.async {
            let image = self.sceneView.snapshot()

            // Check if user is logged in first
            if Auth.auth().currentUser?.uid != nil {
                // logged in; send user to crop screen
                let st = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                let vc = st.instantiateViewController(withIdentifier: "cropVC") as! CropViewController
                vc.modalPresentationStyle = .fullScreen
                self.show(vc, sender: nil) // might change
                vc.loadImageForCrop(image: image)
            } else {
                // not logged in; send to login screen
                // alert user eventually
                let login = AccountViewController()
                (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = login
            }
        
        //}
        
    }
    
    // SYSTEM FUNCTIONS
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(onUserSelected(_:)), name: Notification.Name.init(rawValue: NotificatioType.UserProfileSelectedNotification.rawValue), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Start the AR experience
        DispatchQueue.global(qos: .userInitiated).async {
            self.resetTracking()
            if let configuration = self.session.configuration {
                self.session.run(configuration, options: [.resetTracking])
            }
        }
        // refesh config every 60 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) { [weak self] in
            self?.refreshConfig()
        }
//        var refreshTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(ViewController.refreshConfig), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.pause()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Session management (Image detection setup)
    
    /// Prevents restarting the session while a restart is in progress.
    var isRestartAvailable = true
    
    /// Creates a new AR configuration to run on the `session`.
    /// - Tag: ARReferenceImage-Loading
    func resetTracking() {
   
        // If logged in, show public + own ingineered items
        if Auth.auth().currentUser?.uid != nil {
            // logged in
            self.showToLoggedIn()
        } else {
            // if not logged in, show public images only
            self.showToPublic()
        }
        
    }
    
    typealias completionHandler = (Result<Set<ARReferenceImage>, Error>) -> ()
    // show ingineered items to logged in users
    func showToLoggedIn() {
        reloadArAssets(isPublic: false)
    }
    
    // show ingineered items to users that are not logged in
    func showToPublic() {
        reloadArAssets(isPublic: true)
    }
    
    // MARK: - ARSCNViewDelegate (Image detection results)
    /// - Tag: ARImageAnchor-Visualizing
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        // Get matchUrls from Firebase, so that when ingine model is clicked it goes to the appropriate url
        self.registerGestureRecognizer(matchURL: referenceImage.name ?? "")
        
        updateQueue.async {
            
            // Create a plane to visualize the initial position of the detected image.
            let plane = SCNPlane(width: referenceImage.physicalSize.width,
                                 height: referenceImage.physicalSize.height)
            plane.firstMaterial?.colorBufferWriteMask = .alpha
            let planeNode = SCNNode(geometry: plane)
            //            planeNode.opacity = 0.25
            
            /*
             `SCNPlane` is vertically oriented in its local coordinate space, but
             `ARImageAnchor` assumes the image is horizontal in its local space, so
             rotate the plane to match.
             */
            planeNode.eulerAngles.x = -.pi / 2
            planeNode.renderingOrder = -1
            
            /*
             Image anchors are not tracked after initial detection, so create an
             animation that limits the duration for which the plane visualization appears.
             */
            //            planeNode.runAction(self.imageHighlightAction)
            
            // Add the plane visualization to the scene.
            node.addChildNode(planeNode)
            
            // Put 3d model
            let ingineScene = SCNScene(named: "pin_marker.scn")!
            let ingineNode = ingineScene.rootNode.childNode(withName: "ingine", recursively: true)!
            
            // correct upside down orientation
            ingineNode.eulerAngles.x = (.pi / 8) * 5
            ingineNode.position.z = 0.15
            
            planeNode.addChildNode(ingineNode)
            
        }
        
        DispatchQueue.main.async {
//            let imageName = referenceImage.name ?? ""
            self.statusViewController.cancelAllScheduledMessages()
            self.statusViewController.showMessage("Augmented image detected!")
        }
    }
    
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOut(duration: 0.5),
            .removeFromParentNode()
            ])
    }
    
    // Define tap gesture
    func registerGestureRecognizer(matchURL: String) {
        DispatchQueue.main.async {
            let tap = MyTapGesture(target: self, action: #selector(self.search))
            self.sceneView.addGestureRecognizer(tap)
            tap.url = matchURL
        }
    }
    
    // handle tap gesture on the ingine indicator that reveals the link saved in the image
    @objc func search(sender: MyTapGesture) {
        let sceneView = sender.view as! ARSCNView
        let location = sender.location(in: sceneView)
        let results = sceneView.hitTest(location, options: [SCNHitTestOption.searchMode : 1])
        
        print("user tapped")
        //        guard sender.state == .began else { return }
        for result in results.filter( { $0.node.name != nil }) {
            if result.node.name == "ingine" {
                // open link here
                print("node found")
                
                guard let url = URL(string: sender.url) else {
                    //Show an invalid URL error alert
                    return
                }
                
                // Show the associated link in the in-app browser
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true)
                
            }
        }
    }
    
}

extension ViewController {
    override var supportedInterfaceOrientations:UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}

class MyTapGesture: UITapGestureRecognizer {
    var url = String()
}


//AR session run and updates
extension ViewController {
    func reloadArAssets(isPublic:Bool, userId:String? = nil) {
        guard let userDocID = userId else {
            return
        }
        cancelTimer()
        isReloading = true
        var query = db.collection("pairs").whereField("user", isEqualTo: userDocID).limit(to: 1000)
        
        if isPublic {
            query = query.whereField("public", isEqualTo: true)
        }
        
        query.getDocuments { (querySnapshot, err) in
            guard err == nil,
                let documents = querySnapshot?.documents else {
                return
            }

            var arAssets = [ARImageAsset]()
            
            arAssets = documents.filter { (doc) -> Bool in
                (doc.get("public") as? Bool) == true
            }.filter { (doc) -> Bool in
                ((doc.get("matchURL") as? String) != nil &&
                (doc.get("refImage") as? String) != nil)
            }.map({ (doc) -> ARImageAsset in
                let name = (doc.get("matchURL") as! String)
                let url = (doc.get("refImage") as! String)
                return ARImageAsset(name: name, imageUrl: url)
            })
            
            ARImageDownloadService.main.beginDownloadOperation(imageAssets: arAssets, delegate: self)
            self.isReloading = false
            NotificationCenter.default.post(Notification.progressUpdateNotification(message: "Updating notification", fromStartingIndex: 0, toEndingIndex: arAssets.count))
        }
    }
    
    func removeUnusedAssets(assets:[ARImageAsset]) {
        
        arQueue.sync {
            assets.forEach { (asset) in
                ImageLoadingService.main.remove(forKey: asset.imageUrl)
                if let index = arAssets.firstIndex(of: asset) {
                    arAssets.remove(at: index)
                }
            }
        }
    }
    
   @objc func cycleNextArAssets(_ sender:Timer) {
        guard isReloading == false else {
            cancelTimer()
            return
        }
    
        DispatchQueue.init(label: "back").async { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.cancelTimer()
            
            let semaphore = DispatchSemaphore(value: 1)
            var imagesToAdd = Set<ARReferenceImage>()
            
            //this while loop assumes that there will be a valid arImage reference in the list
            //this is could create an infinite loop in
            while(strongSelf.arAssets.count > 0 && imagesToAdd.count < 1) {
                var endIndex = min((strongSelf.currentImgIndex + strongSelf.maxNumImages), (strongSelf.arAssets.count - 1))
                var imagesToRemove = [ARImageAsset]()
                for i in strongSelf.currentImgIndex...endIndex  {
                    guard strongSelf.isReloading == false else { break }
                    
                    let asset = strongSelf.arAssets[i]
                    
                    guard let imageData = ImageLoadingService.main.get(forKey: asset.imageUrl),
                        let image = UIImage(data: imageData as Data),
                        let cgImage = image.cgImage else {
                        imagesToRemove.append(asset)
                        continue
                    }
                    
                    let newReferenceImage = ARReferenceImage.init(cgImage, orientation: .up, physicalWidth: CGFloat(0.5))
                    newReferenceImage.name = asset.name

                    if #available(iOS 13.0, *) {
                        newReferenceImage.validate { (error) in
                            defer { semaphore.signal() }
                            
                            guard error == nil else {
                                imagesToRemove.append(asset)
                                return
                            }
                            
                            imagesToAdd.insert(newReferenceImage)
                        }
                        semaphore.wait()
                    } else {
                        imagesToAdd.insert(newReferenceImage)
                    }
                }
                strongSelf.removeUnusedAssets(assets: imagesToRemove)
                strongSelf.currentImgIndex = endIndex < (strongSelf.arAssets.count - 1) ? endIndex : 0
            }
            
            guard strongSelf.isReloading == false else {
                strongSelf.cancelTimer()
                return
            }
            
            strongSelf.resetArImageConfiguration(withNewImage: imagesToAdd)
            //strongSelf.startTimer()
            print("cycled through arImages at index \(strongSelf.currentImgIndex)")
        }
    }
    
    
    func resetArImageConfiguration(withNewImage imageSets:Set<ARReferenceImage>) {
        
        if #available(iOS 12.0, *) {
            let configuration = ARImageTrackingConfiguration()
            configuration.maximumNumberOfTrackedImages = imageSets.count
            configuration.trackingImages = imageSets
            DispatchQueue.main.sync { [weak self] in
                //self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
                self?.session.run(configuration, options: .resetTracking)
                self?.statusViewController.scheduleMessage("Look around to detect images", inSeconds: 7.5, messageType: .contentPlacement)
            }
        } else {
            // Fallback on earlier versions
            DispatchQueue.main.async {
                self.statusViewController.scheduleMessage("Sorry. You do not have an iPhone with ARkit.", inSeconds: 7.5, messageType: .contentPlacement)
            }
        }
        
    }
}

//ARImageDownloadServiceDelegate methods
extension ViewController: ARImageDownloadServiceDelegate {
    
    func onImageDownloaded(status: ARImageDownloadStatus, asset: ARImageAsset?, index: Int, total: Int) {
        
        arQueue.sync {
            guard status != .Error,
                let arAsset = asset,
                arAssets.contains(arAsset) == false else {
                print("ref image could not be downloaded. Error: \(status)")
                NotificationCenter.default.post(Notification.progressUpdateNotification(message: "Skipping item \(index)", fromStartingIndex: index, toEndingIndex: total))
                return
            }
        
            arAssets.append(arAsset)
        }
        NotificationCenter.default.post(Notification.progressUpdateNotification(message: "Updating with item \(index)", fromStartingIndex: index, toEndingIndex: total))
    }
    
    func onOperationCompleted(status:ARImageDownloadStatus) {
        NotificationCenter.default.post(Notification.progressEndNotification(message: "Update complete"))
        
        guard status != .Error else {
            print("all images could not be downloaded. Error: \(status)")
            return
        }
        
        NotificationCenter.default.post(Notification.progressEndNotification(message: "Update Completed"))
        cycleNextArAssets(Timer.init())
        //startTimer()
    }
    
    
}

extension ViewController {
    
    func startTimer() {
        guard arImageCycleTimer == nil else { return }
        
        arImageCycleTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(cycleNextArAssets(_:)), userInfo: nil, repeats: true)
        
        arImageCycleTimer?.fire()
    }
    
    func cancelTimer() {
        guard arImageCycleTimer != nil else { return }
        arImageCycleTimer?.invalidate()
        arImageCycleTimer = nil
    }
}

extension ViewController {
    @IBAction func handleUserSelect(_ sender:UIButton) {
        performSegue(withIdentifier: "selectUser", sender: nil)
    }
}

extension ViewController {
    @objc func onUserSelected(_ notification: Notification) {
        guard let dict = notification.userInfo,
            let documentId = dict[NotificationProgressUserInfoType.UserDocumentId.rawValue] as? String else {
                return
        }
        
        reloadArAssets(isPublic: (Auth.auth().currentUser?.uid != nil), userId: documentId)
        
        DispatchQueue.main.async {
            self.userButton?.setTitle(documentId, for: .normal)
        }
    }
}

extension ViewController {
    func openTutorialPage(isForFirstTimers: Bool = false) {
        guard !isForFirstTimers || UserDefaults.getValue(forSetting: .DidViewTutorialPage) == nil else {
            return
        }
        
        self.performSegue(withIdentifier: "tutorialSegue", sender: nil)
    }
}
