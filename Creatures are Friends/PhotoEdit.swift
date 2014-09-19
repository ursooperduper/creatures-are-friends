//
//  PhotoEdit.swift
//  Creatures are Friends
//
//  Created by Sarah Kuehnle on 9/11/14.
//  Copyright (c) 2014 Sarah Kuehnle. All rights reserved.
//

import UIKit
import Photos

class PhotoEdit: UIViewController, UIGestureRecognizerDelegate {
    
    let characterCount = 20
    var assetCollection: PHAssetCollection!
    var photos: PHFetchResult!
    var index: Int!
    var imgLocationSet: CGPoint!
    var totalScale: CGFloat = 1
    var totalRotation: CGFloat = 0
    var charLocation: CGPoint = CGPointZero
    
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var imgCharacter1: UIImageView!
    @IBOutlet var viewImage: UIView!
    
    // Creates a composite of the character head and photo
    func getComposite(topImg: UIImage, bottomImg: UIImage) -> UIImage {
        // create a context, this will store the image
        var context: CIContext = CIContext(options: nil)
        // Create CIImage versions of the top and bottom images
        var fgImg = CIImage(image: topImg)
        var bgImg = CIImage(image: bottomImg)
        
        println("fgImg size: \(fgImg.extent())")
        println("bgImg size: \(bgImg.extent())")
        
        
        var compFilter: CIFilter = CIFilter(name: "CISourceOverCompositing")
        compFilter.setValue(fgImg, forKey: "inputImage")
        compFilter.setValue(bgImg, forKey: "inputBackgroundImage")
        var result = compFilter.valueForKey("outputImage") as CIImage
        // Get the size of the return image
        var extent = result.extent()
        println("result of filter size: \(extent)")
        var renderedImage = context.createCGImage(result, fromRect: extent)
        var finalImage = UIImage(CGImage: renderedImage)
        println("finalImage size: \(finalImage?.size)")
        
        return finalImage!
    }
    
    // Returns a random integer between two specified numbers
    func randomInt(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    // Retrieves an image using PHImageManager, the target size is of the screen dimensions.
    func displayPhoto() {
        let imageManager = PHImageManager.defaultManager()
        var optionsForImage: PHImageRequestOptions = PHImageRequestOptions()
        optionsForImage.resizeMode = .Exact
        optionsForImage.deliveryMode = .HighQualityFormat
        
        var id = imageManager.requestImageForAsset(self.photos[self.index] as PHAsset, targetSize: CGSize(width: 320, height: 460), contentMode: .AspectFit, options: optionsForImage, resultHandler: {(result, info) in
            self.imgView.image = result
        })
    }
  
    // Convert a UIView to a UIImage so we can save a screenshot of the selected image
    func getUIImageFromView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContext(view.bounds.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        var graphicImg: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return graphicImg
    }
    
    func addNewAssetWithImage(image: UIImage, toAlbum album:PHAssetCollection) {
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            // Request creating an asset from the image.
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            
            // Request editing the album.
            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: album)
            
            // Get a placeholder for the new asset and add it to the album editing request.
            let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
            albumChangeRequest.addAssets([assetPlaceholder])
            
            }, completionHandler: { success, error in
                NSLog("Finished adding asset. %@", (success ? "Success" : error))
        })
    }
    
    // Button Actions
    @IBAction func btnCancel(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    @IBAction func btnExport(sender: AnyObject) {
        println("Save Image")
        
        // Using the Screenshot approach
        //let imageToSave: UIImage = getUIImageFromView(viewImage)
        
        let imageToSave: UIImage = getComposite(self.imgCharacter1.image!, bottomImg: self.imgView.image!)
        addNewAssetWithImage(imageToSave, toAlbum: self.assetCollection)
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // ** GESTURES **
    // Gesture: Double Tap
    @IBOutlet var gestureDoubleTap: UITapGestureRecognizer!
    @IBAction func handleGestureDoubleTap(recognizer: UITapGestureRecognizer) {
        var location = recognizer.locationInView(self.view)
        imgLocationSet = location
        imgCharacter1.hidden = false
        imgCharacter1.center = location
        
        var character = UIImage(named: "head_" + String(randomInt(1, max: 20)))
        imgCharacter1.image = character
    }

    // Gesture: Pan
    // Allow the user to drag the character around the screen.
    @IBOutlet var gesturePanCharacter: UIPanGestureRecognizer!
    @IBAction func handleGesturePanCharacter(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x,
            y:recognizer.view!.center.y + translation.y)
        
        charLocation.x += translation.x
        charLocation.y += translation.y
        
        println("X: \(charLocation.x) -- Y: \(charLocation.y)")
        
        recognizer.setTranslation(CGPointZero, inView: self.view)
        
    }
    
    // Gesture: Pinch (to scale)
    @IBOutlet var gesturePinchCharacter: UIPinchGestureRecognizer!
    @IBAction func handleGesturePinchCharacter(recognizer: UIPinchGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformScale(recognizer.view!.transform, recognizer.scale, recognizer.scale)
        totalScale *= recognizer.scale
        println("Total Scale: \(totalScale)")
        
        recognizer.scale = 1
    }
    
    // Gesture: Rotate
    @IBOutlet var gestureRotateCharacter: UIRotationGestureRecognizer!
    @IBAction func handleGestureRotateCharacter(recognizer: UIRotationGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformRotate(recognizer.view!.transform, recognizer.rotation)
        
        totalRotation += recognizer.rotation
        println("Total Rotation: \(totalRotation)")
        
        recognizer.rotation = 0
    }
    
    
    // Controller override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(gestureDoubleTap)
        imgCharacter1.addGestureRecognizer(gesturePanCharacter)
        imgCharacter1.addGestureRecognizer(gesturePinchCharacter)
        imgCharacter1.addGestureRecognizer(gestureRotateCharacter)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setToolbarHidden(false, animated: false)
        self.displayPhoto()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: false)
        self.becomeFirstResponder()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if(event.subtype == UIEventSubtype.MotionShake) {
            var character = UIImage(named: "head_" + String(randomInt(1, max: characterCount)))
            imgCharacter1.image = character
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // Optional method implementations
    
    // Implement gesture delegate recognizer optional function to allow the user to perform multiple gesturesx
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }

}
