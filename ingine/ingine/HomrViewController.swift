//
//  HomrViewController.swift
//  ingine
//
//  Created by Manish Dadwal on 18/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var appleSignInButton: UIButton!
    
    //MARK:Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // setup the UI
    private func setupUI(){
        // give radius to buttons
        loginButton.setRadius(8)
        signUpButton.setRadius(8)
        appleSignInButton.setRadius(8)
    }
    
    
//MARK: Actions
    
    @IBAction func appleSignIn(_ sender: UIButton) {
    }
    
    @IBAction func signUp(_ sender: UIButton) {
    }
    
    @IBAction func login(_ sender: UIButton) {
    }
}
