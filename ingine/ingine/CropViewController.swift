//
//  CropViewController.swift
//  ingine
//
//  Created by McNels on 4/3/19.
//  Copyright © 2019 ingine. All rights reserved.
//

import UIKit

class CropViewController: PortraitViewController {
    @IBOutlet weak var mImageView: UIImageView!
    let cropView = SECropView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //in order: top left, top right, bottom right, bottom left
//        cropView.configureWithCorners(corners: [CGPoint(x: 150, y: 800),
//                                                CGPoint(x: 1150, y: 800),
//                                                CGPoint(x: 1150, y: 1800),
//                                                CGPoint(x: 150, y: 1800)], on: mImageView)
        // Screen width. // view.frame.size.height // UIScreen.main.bounds.width / UIScreen.main.nativeScale
        
        let screenWidth: CGFloat = UIScreen.main.bounds.width * UIScreen.main.nativeScale
        let screenHeight: CGFloat = UIScreen.main.bounds.height * UIScreen.main.nativeScale
//        print(UIScreen.main.bounds.width)
//        print(UIScreen.main.bounds.height)
//        print(UIScreen.main.scale)
//        print(UIScreen.main.nativeScale)
        
        cropView.configureWithCorners(corners: [CGPoint(x: 100, y: 100),
                                                CGPoint(x: screenWidth - 100, y: 100),
                                                CGPoint(x: screenWidth - 100, y: screenHeight - 100),
                                                CGPoint(x: 100, y: screenHeight - 100)], on: mImageView)

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
