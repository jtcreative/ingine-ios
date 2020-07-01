//
//  TutorialViewController.swift
//  ingine
//
//  Created by James Timberlake on 6/16/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import Foundation
import UIKit

class TutorialViewController : UIPageViewController {
    
    let closeButton = UIButton()
    let backButton = UIButton()
    let nextButton = UIButton()
    lazy var pageViews : [UIViewController] = {
        return [
        TutorialImageViewController(imageName: "tutorial1"),
        TutorialImageViewController(imageName: "tutorial2"),
        TutorialImageViewController(imageName: "tutorial3"),
        TutorialImageViewController(imageName: "tutorial4"),
        TutorialImageViewController(imageName: "tutorial5"),
        TutorialImageViewController(imageName: "tutorial6")        ]
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.setSetting(setting: .DidViewTutorialPage, asValue: true)
        setViewControllers([pageViews.first!], direction: .forward, animated: true, completion: { result in
            
        })
        dataSource = self
        delegate = self
        
        closeButton.setTitle("Close", for: .normal)
        backButton.setTitle("Back", for: .normal)
        nextButton.setTitle("Next", for: .normal)
        
        closeButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        
        backButton.addTarget(self, action: #selector(backPage), for: .touchUpInside)
        backButton.backgroundColor = .gray
        backButton.alpha = 0.7
        backButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        nextButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        nextButton.backgroundColor = .gray
        nextButton.alpha = 0.7
        nextButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        view.addSubview(closeButton)
        view.addSubview(backButton)
        view.addSubview(nextButton)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        closeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        backButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        nextButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant:  -20).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        updateButtons(atIndex: 0)
    }
}

extension TutorialViewController : UIPageViewControllerDataSource {
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
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        guard let vc = viewControllers?.first,
            let index = pageViews.firstIndex(of:vc) else {
            return 1
        }
        updateButtons(atIndex: (index))
        return 1
    }
}

extension TutorialViewController : UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let vc = previousViewControllers.first,
            let index = pageViews.firstIndex(of:vc) else {
            return
        }
        updateButtons(atIndex: (index + 1))
    }
}

extension TutorialViewController {
    @objc func closeView() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func backPage() {
        guard let currentPage = viewControllers?.first,
              let currentIndex = pageViews.firstIndex(of: currentPage),
              currentIndex > 0 else {
            return
        }
    
        let prevIndex = pageViews.index(before: currentIndex)
        setViewControllers([pageViews[prevIndex]], direction: .reverse, animated: true, completion: nil)
        updateButtons(atIndex: prevIndex)
    }
    
    @objc func nextPage() {
        guard let currentPage = viewControllers?.first,
              let currentIndex = pageViews.firstIndex(of: currentPage),
            currentIndex < (pageViews.count - 1) else {
                closeView()
            return
        }
    
        let nextIndex = pageViews.index(after: currentIndex)
        setViewControllers([pageViews[nextIndex]], direction: .forward, animated: true, completion: nil)
        updateButtons(atIndex: nextIndex)
    }
    
    func updateButtons(atIndex index:Int) {
        guard index > 0 else {
            backButton.isHidden = true
            nextButton.setTitle("Next", for: .normal)
            return
        }
        
        guard index < (pageViews.count - 1) else {
            nextButton.setTitle("Finish", for: .normal)
            return
        }
        
        backButton.isHidden = false
        nextButton.setTitle("Next", for: .normal)
    }
}

