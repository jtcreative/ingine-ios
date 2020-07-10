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
    
    lazy var pageViews : [UIViewController] = {
        return [
            UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ARViewController"),
            UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Profile")
        ]
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if nil == Auth.auth().currentUser?.uid {
            // send to login screen
            let login = AccountViewController()
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = login
        } else {
            self.openTutorialPage(isForFirstTimers: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewControllers([pageViews.first!], direction: .forward, animated: true, completion: { result in
            
        })
        dataSource = self
    }
    
}

extension MainViewController {
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
