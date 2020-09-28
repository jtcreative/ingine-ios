//
//  BaseViewController.swift
//  ingine
//
//  Created by Manish Dadwal on 25/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupKeyboardObservers()
    }
    
    // Keybaord
    func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //Handle when keyboard will appear
    @objc func handleKeyboardWillShow(notification: Notification){
        //get keyboard height
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let height = keyboardFrame.cgRectValue.height
        let move = height/4

        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = keyboardDuration.doubleValue

        view?.frame.origin.y = -move

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    //Handle when keyboard will disappear
    @objc func handleKeyboardWillHide(notification: Notification){
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = keyboardDuration.doubleValue
        view?.frame.origin.y  = 0
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    //Show Alert
    func displayAlert(title: String, message: String) {
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
           alert.addAction(defaultAction)
           self.present(alert, animated: true, completion: nil)
       }
}
