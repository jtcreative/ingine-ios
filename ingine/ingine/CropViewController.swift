//
//  CropViewController.swift
//  ingine
//
//  Created by McNels on 4/3/19.
//  Copyright © 2019 ingine. All rights reserved.
//

import UIKit

class CropViewController: UIViewController {
    @IBOutlet weak var mImageView: UIImageView!
    let cropView = SECropView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cropView.configureWithCorners(corners: [CGPoint(x: 150, y: 800),
                                                CGPoint(x: 1150, y: 800),
                                                CGPoint(x: 1150, y: 1800),
                                                CGPoint(x: 150, y: 1800)], on: mImageView)

    }
    
    func loadImageForCrop(image: UIImage){
        self.mImageView.image = image
    }
    
    @IBAction func saveImg(_ sender: Any) {
        do {
            guard let corners = cropView.cornerLocations else { return }
            guard let image = mImageView.image else { return }
            
            let croppedImage = try SEQuadrangleHelper.cropImage(with: image, quad: corners)
            
            performSegue(withIdentifier: "doCrop", sender: croppedImage)
        } catch let error as SECropError {
            print(error)
        } catch {
            print("Something went wrong, are you feeling OK?")
        }
    }
    

    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        guard let vc = segue.destination as? ImageViewController else { return }
        guard let img = sender as? UIImage else { return }
        vc.image = img
    }

}
