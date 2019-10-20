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

class ViewController: UIViewController, ARSCNViewDelegate {
    var db: Firestore!
    
    // Scene initializations
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var blurView: UIVisualEffectView!
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
        }
        
//        resetTracking()
        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
    }
    
    @objc func refreshConfig()
    {
        self.restartExperience()
    }
    
    // handle swipe gestures from home screen
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            print("Swipe Left")
            if isLoggedIn() {
                // send to profile view
                performSegue(withIdentifier: "toProfile", sender: nil)
            } else {
                let login = AccountViewController()
                (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = login
            }
            
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Start the AR experience
        DispatchQueue.global(qos: .userInitiated).async {
            self.resetTracking()
            if let configuration = self.session.configuration {
                self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
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
            
            self.showToLoggedIn { (result) in
                switch result {
                    case .success (let refImgSet) :
                        var configuration:ARConfiguration!
                        if #available(iOS 12.0, *) {
                            configuration = ARImageTrackingConfiguration()
                            (configuration as! ARImageTrackingConfiguration).maximumNumberOfTrackedImages = refImgSet.count
                            (configuration as! ARImageTrackingConfiguration).trackingImages = refImgSet
                            
                        } else {
                            // Fallback on earlier versions
                        }
                        
                        DispatchQueue.main.async {
                            self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
                            self.statusViewController.scheduleMessage("Look around to detect images", inSeconds: 7.5, messageType: .contentPlacement)
                        }
                    
                    case .failure (let error) :
                        print("ref images could not be downloaded. Error: \(error)")
                    
                }
                
            }
        } else {
            // if not logged in, show public images only
            self.showToPublic { (result) in
                switch result {
                case .success (let refImgSet) :
                    var configuration:ARConfiguration!
                    if #available(iOS 12.0, *) {
                        configuration = ARImageTrackingConfiguration()
                        (configuration as! ARImageTrackingConfiguration).maximumNumberOfTrackedImages = refImgSet.count
                        (configuration as! ARImageTrackingConfiguration).trackingImages = refImgSet
                        
                    } else {
                        // Fallback on earlier versions
                    }
                    
                    DispatchQueue.main.async {
                        self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
                        self.statusViewController.scheduleMessage("Look around to detect images", inSeconds: 7.5, messageType: .contentPlacement)
                    }
                    
                case .failure (let error) :
                    print("ref images could not be downloaded. Error: \(error)")
                    
                }
                
            }
        }
        
    }
    
    typealias completionHandler = (Result<Set<ARReferenceImage>, Error>) -> ()
    // show ingineered items to logged in users
    func showToLoggedIn(_ completion: @escaping completionHandler) {
        var listUrl : [String:String] = ["":""]
        var newReferenceImages = Set<ARReferenceImage>()
        
        // Email login
        db.collection("pairs").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting ingineered items: \(err)")
                completion(.failure(err))
            } else {
                print("no error getting ingineered items")
                // filter out public/private ingineered items around here
                for document in querySnapshot!.documents {
                    
                    // display public items
                    if document.get("public") as? Bool == true {
                        // add refimage as key and matchUrl as value
                        listUrl[document.data()["refImage"] as! String] = document.data()["matchURL"] as? String
                    }
                    // display items that the user uploaded regardless if they are public or not
                    if document.get("user") as? String == Auth.auth().currentUser?.email {
                        // add refimage as key and matchUrl as value
                        listUrl[document.data()["refImage"] as! String] = document.data()["matchURL"] as? String
                    }
                    
                }
                
                // Remove empty entry at the beginning of listUrl
                listUrl.removeValue(forKey: "")
                var count : Int = 0
                
                DispatchQueue.global(qos: .background).async {
                    // Create a ref image out of the images in firebase
                    for url in listUrl.keys {
                        count = count + 1
                        let imageUrl = URL(string: url)!
                        let imageData:NSData = NSData(contentsOf: imageUrl)!
                        let image = UIImage(data: imageData as Data)
                        let cgImage = image!.cgImage
                        
                        // TODO get physical width from image metadata of the image
                        let newReferenceImage = ARReferenceImage.init(cgImage!, orientation: .up, physicalWidth: 0.2)
                        //                    newReferenceImage.name = "Test Image \(count)"
                        newReferenceImage.name = listUrl[url]
                        newReferenceImages.insert(newReferenceImage)
                    }
                    
                    completion(.success(newReferenceImages))
                }
//                var configuration:ARConfiguration!
//                if #available(iOS 12.0, *) {
//                    configuration = ARImageTrackingConfiguration()
//                    (configuration as! ARImageTrackingConfiguration).maximumNumberOfTrackedImages = newReferenceImages.count
//                    (configuration as! ARImageTrackingConfiguration).trackingImages = newReferenceImages
//
//                } else {
//                    // Fallback on earlier versions
//                }
//
//                self.session.run(configuration)
//                self.statusViewController.scheduleMessage("Look around to detect images", inSeconds: 7.5, messageType: .contentPlacement)
            }
        }
        
        
    }
    
    // show ingineered items to users that are not logged in
    func showToPublic(_ completion: @escaping completionHandler) {
        var listUrl : [String:String] = ["":""]
        var newReferenceImages = Set<ARReferenceImage>()
        
        // if not logged in, show public images only
        db.collection("pairs").whereField("public", isEqualTo: true).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting ingineered items: \(err)")
                completion(.failure(err))
            } else {
                print("no error getting ingineered items")
                for document in querySnapshot!.documents {
                    // add refimage as key and matchUrl as value
                    listUrl[document.data()["refImage"] as! String] = document.data()["matchURL"] as? String
                }
                
                // Remove empty entry at the beginning of listUrl
                listUrl.removeValue(forKey: "")
                var count : Int = 0
                
                DispatchQueue.global(qos: .background).async {
                    // Create a ref image out of the images in firebase
                    for url in listUrl.keys {
                        count = count + 1
                        let imageUrl = URL(string: url)!
                        let imageData:NSData = NSData(contentsOf: imageUrl)!
                        let image = UIImage(data: imageData as Data)
                        let cgImage = image!.cgImage
                        
                        // TODO get physical width from image metadata of the image
                        let newReferenceImage = ARReferenceImage.init(cgImage!, orientation: .up, physicalWidth: 0.2)
                        //                    newReferenceImage.name = "Test Image \(count)"
                        newReferenceImage.name = listUrl[url]
                        newReferenceImages.insert(newReferenceImage)
                    }
                    
                    completion(.success(newReferenceImages))
                }
//                var configuration:ARConfiguration!
//                if #available(iOS 12.0, *) {
//                    configuration = ARImageTrackingConfiguration()
//                    (configuration as! ARImageTrackingConfiguration).maximumNumberOfTrackedImages = newReferenceImages.count
//                    (configuration as! ARImageTrackingConfiguration).trackingImages = newReferenceImages
//
//                } else {
//                    // Fallback on earlier versions
//                }
//
//                self.session.run(configuration)
//                self.statusViewController.scheduleMessage("Look around to detect images", inSeconds: 7.5, messageType: .contentPlacement)
            }
        }
        
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
            let ingineScene = SCNScene(named: "ingine.scn")!
            let ingineNode = ingineScene.rootNode.childNode(withName: "ingine", recursively: true)!
            
            // correct upside down orientation
            ingineNode.eulerAngles.x = .pi
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

class MyTapGesture: UITapGestureRecognizer {
    var url = String()
}


