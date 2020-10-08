//
//  MainViewController.swift
//  ingine
//
//  Created by James Timberlake on 6/30/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth




class MainViewController : UIPageViewController {
    
    var currentPageIndex = 1
    
    lazy var pageViews : [UIViewController] = {
        return [
            UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Profile"),
            UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ARViewController"),
            UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UserViewController"),
            UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginViewController")
        ]
    }()
    
    lazy var bottomView : BottomBar = {
        return BottomBar()
    }()
    
    /*
     [
         UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ARViewController"),
         UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeViewController"),
          UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginViewController"),
          UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SignUpViewController"),
         UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Profile"),
         UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UserViewController"),
         
      
     ]
     
     **/
    
    
    var data:Any?
    var selectedUserID:Any?
    var isOtherUser:Bool?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if nil == Auth.auth().currentUser?.uid {
            // send to login screen
//            let login = AccountViewController()
//            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = login
     //       goToController(HomeViewController.self)
            
        } else {
            self.openTutorialPage(isForFirstTimers: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewControllers([pageViews[currentPageIndex]], direction: .forward, animated: true, completion: { result in
            self.createNavigationView()
        })
        

        dataSource = nil
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
    
}

extension MainViewController {
    public func createNavigationView() {
        view.addSubview(bottomView)
        // add constrainsts
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        bottomView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        bottomView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0 ).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        // add actions to button
        bottomView.cameraButton.addTarget(self, action: #selector(self.goToArPage), for: .touchUpInside)
        bottomView.searchButton.addTarget(self, action: #selector(self.goToSearchScreen), for: .touchUpInside)
        bottomView.profileButton.addTarget(self, action: #selector(self.goToProfileSetting), for: .touchUpInside)
        
        bottomView.contentView.setCustomGradient([UIColor.black, UIColor.yellow])
    }
    
    @objc func goToSearchScreen(){
        if isLoggedIn() {
            if let mainViewController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? MainViewController {
                let searchVc = self.storyboard?.instantiateViewController(identifier: "UserViewController") as! UserViewController
                mainViewController.goToController(searchVc)
            }
        }
    }
    
    @objc func goToArPage(){
        guard currentPageIndex != 1 else {
            guard let vcs = self.viewControllers,
                let arPageViewController = vcs[0] as? ViewController else { return }
            arPageViewController.takePhotoAction()
            return
        }
        if isLoggedIn() {
            if let mainViewController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? MainViewController {
                let searchVc = self.storyboard?.instantiateViewController(identifier: "ARViewController") as! ViewController
                mainViewController.goToController(searchVc)
            }
        }
    }

    @IBAction func goToProfileSetting() {
        if isLoggedIn() {
            // send to profile view
            selectedUserID = nil
            isOtherUser = nil
            
            if let mainViewController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? MainViewController {
                let profileVc = self.storyboard?.instantiateViewController(identifier: "Profile") as! ProfileViewController
                mainViewController.goToController(profileVc)
            }
        } else {
            
            if let mainViewController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? MainViewController {
                let profileVc = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
                mainViewController.goToController(profileVc)
            }
            
            
//            let login = LoginViewController()
//            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = login
        }
    }
}


extension MainViewController {
    
    func goToController<T:UIViewController>(_ vc:T){
        for vc in pageViews {
            if vc is T {
                if let currentIndex = pageViews.firstIndex(of: vc){
                    let direction = currentIndex < currentPageIndex ? NavigationDirection.reverse : NavigationDirection.forward
                    currentPageIndex = currentIndex
                    setViewControllers([pageViews[currentIndex]], direction: direction, animated: true, completion: nil)
                }
            }
        }
        
    }

    
    func backPage() {
        guard let currentPage = viewControllers?.first,
              let currentIndex = pageViews.firstIndex(of: currentPage),
              currentIndex > 0 else {
            return
        }
    
        let prevIndex = pageViews.index(before: currentIndex)
        setViewControllers([pageViews[prevIndex]], direction: .reverse, animated: true, completion: nil)
    }
    
    func nextPage() {
        guard let currentPage = viewControllers?.first,
              let currentIndex = pageViews.firstIndex(of: currentPage),
            currentIndex < (pageViews.count - 1) else {
            return
        }
    
        let nextIndex = pageViews.index(after: currentIndex)
        setViewControllers([pageViews[nextIndex]], direction: .forward, animated: true, completion: nil)
    }
}

extension MainViewController {
    private func openTutorialPage(isForFirstTimers: Bool = false) {
        guard !isForFirstTimers || UserDefaults.getValue(forSetting: .DidViewTutorialPage) == nil else {
            return
        }
        
        self.performSegue(withIdentifier: "tutorialSegue", sender: nil)
    }
}

extension MainViewController : UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = pageViews.firstIndex { (vc) -> Bool in
             return (vc == viewController)
         }

         guard index != nil,
                index! > 0 else {
             return nil
         }

        let beforeIndex = pageViews.index(before: index!)
        return pageViews[beforeIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
         let index = pageViews.firstIndex { (vc) -> Bool in
             return (vc == viewController)
         }

         guard index != nil,
             index! < (pageViews.count - 1) else {
             return nil
         }

        let nextIndex = pageViews.index(after: index!)
        return pageViews[nextIndex]
    }
    
    
}

extension MainViewController {
    override var supportedInterfaceOrientations:UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
}
