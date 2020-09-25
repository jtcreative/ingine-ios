//
//  HomrViewController.swift
//  ingine
//
//  Created by Manish Dadwal on 18/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import UIKit
import FirebaseAuth

class HomeViewController: PortraitViewController {

    //MARK: Outlets
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var appleSignInButton: UIButton!
    @IBOutlet weak var arImageView: UIView!
    @IBOutlet weak var arImage: UIImageView!
    
    //MARK: Outlets
    
    var imageFrom: UIImage?
    var arAssetName:String?
    var arAssetUrl:String?
    var visibility:Bool?
    
    //MARK:Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // isLoggedIn()
    }
    
    // setup the UI 836269
    private func setupUI(){
        // give radius to buttons
        loginButton.setRadius(8)
        signUpButton.setRadius(8)
        appleSignInButton.setRadius(8)
        arImageView.setRadius(12)
        
        // set gradient
        view.setGradientBackground()
        
        if let main = self.parent as? MainViewController{
            if let value = main.data as? SendARData{
                arImage.image = value.image
            }
        }
        
    }
    
  
    // Check if user is logged in
    func isLoggedIn() {
        if Auth.auth().currentUser?.uid != nil {
            self.openMainViewController()
        }else{
            self.openMainViewController()
        }
        
    }
    // move to main page
    func openMainViewController() {
           DispatchQueue.main.async {
               // log user in, and show home screen
               // Go back to homescreen
            let arVC = self.storyboard?.instantiateViewController(identifier: "ARViewController") as! ViewController
            
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = arVC
           }
       }
    



//MARK: Actions
    
    @IBAction func appleSignIn(_ sender: UIButton) {
        print("appleSignIn")
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        
        let signup = storyboard?.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
       if let mainViewController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? MainViewController {
        mainViewController.goToController(signup)
       }
    }
    
    @IBAction func login(_ sender: UIButton) {
        let login = storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
        
        if let mainViewController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? MainViewController {
                   mainViewController.goToController(login)
               }
        
    }
}
