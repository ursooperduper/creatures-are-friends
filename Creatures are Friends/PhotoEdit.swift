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
    
    var assetCollection: PHAssetCollection!
    var photos: PHFetchResult!
    var index: Int = 0
    
    var characterPosX: CGFloat!
    var characterPosY: CGFloat!
    var characterScale: CGFloat!
    var characterRotation: CGFloat!
    var characterWidth: CGFloat!
    var characterHeight: CGFloat!
    
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var imgCharacter1: UIImageView!
    let characterCount = 20
    
    var imgLocationSet: CGPoint!
    
    // Returns a random integer between two specified numbers
    func randomInt(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    // Sets up image
    func setupImage(fgImg: UIImage, bgImg: CIImage) -> CIImage {
        let backgroundImg = bgImg
        let foregroundImg = CIImage(image: fgImg)
        
        let filter = CIFilter(name: "CISourceOverCompositing")
        filter.setValue(foregroundImg, forKey: "inputImage")
        filter.setValue(backgroundImg, forKey: "inputBackgroundImage")
        
        let newImage: CIImage = filter.outputImage
        return newImage
    }
    
    // Retrieves an image using PHImageManager, the target size is of the screen dimensions. (but will need to be adapted for iPhone 5, 6, 6+)
    func displayPhoto() {
        let imageManager = PHImageManager.defaultManager()
        //var optionsForImage: PHImageRequestOptions = PHImageRequestOptions()
        
        var id = imageManager.requestImageForAsset(self.photos[self.index] as PHAsset, targetSize: CGSize(width: 320, height: 459), contentMode: .AspectFit, options: nil, resultHandler: {(result, info) in
            self.imgView.image = result
        })
    }
    
    // Button Actions
    @IBAction func btnCancel(sender: AnyObject) {
        self.navigationController.popToRootViewControllerAnimated(true)
    }
    @IBAction func btnExport(sender: AnyObject) {
        println("Save Image")
        // Save and share should probably go here
//        var alert = UIAlertController(title: "Save", message: "Would you like to save this image?", preferredStyle: .Alert)
//        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {(alertAction) in
//            
//            var asset: PHAsset = self.photos[self.index] as PHAsset
//            
//            asset.requestContentEditingInputWithOptions(nil, completionHandler: {(editingInput: PHContentEditingInput!, info) in
//                
//                var url: NSURL = editingInput.fullSizeImageURL
//                var orientation = editingInput.fullSizeImageOrientation
//                
//                var inputImage: CIImage = CIImage(contentsOfURL: url, options: nil)
//                inputImage = inputImage.imageByApplyingOrientation(orientation)
//                
//                
//                var theImage = self.setupImage(self.imgCharacter1.image, bgImg: inputImage)
//                
//                self.imgView.image = UIImage(CIImage: theImage)
//                self.imgCharacter1.hidden = true
//                
//                var output: PHContentEditingOutput = PHContentEditingOutput(contentEditingInput: editingInput)
//                
//                var context = CIContext(options: nil)
//                
//                var cgImg: CGImageRef = context.createCGImage(theImage, fromRect: theImage.extent())
//                
//                var pixelData: NSData! = UIImagePNGRepresentation(UIImage(CGImage: cgImg))
//                pixelData.writeToURL(output.renderedContentURL, atomically: true)
//                
//                var imgData: NSDictionary = ["scale":1, "rotation":0]
//                
//                var archivedData: NSData = NSKeyedArchiver.archivedDataWithRootObject(imgData)
//               
//                var adjustmentData = PHAdjustmentData(formatIdentifier: "com.sooperduper", formatVersion: "1.0", data: archivedData)
//                
//                output.adjustmentData = adjustmentData
//                
//                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
//                
//                    var request: PHAssetChangeRequest = PHAssetChangeRequest(forAsset: asset)
//                    request.contentEditingOutput = output
//                    
//                    }, completionHandler: {(success, error) in
//                        NSLog("Image created -> %@", success ? "Success" : "Error")
//                        NSLog("Error data -> %@", error)
//                })
//            })
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: {(alertAction) in
//            alert.dismissViewControllerAnimated(true, completion: nil)
//        }))
//        self.presentViewController(alert, animated: true, completion: nil)
        
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
        
        characterHeight = imgCharacter1.bounds.height
        characterWidth = imgCharacter1.bounds.width
    }

    // Gesture: Pan
    // Allow the user to drag the character around the screen.
    @IBOutlet var gesturePanCharacter: UIPanGestureRecognizer!
    @IBAction func handleGesturePanCharacter(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x,
            y:recognizer.view!.center.y + translation.y)
        recognizer.setTranslation(CGPointZero, inView: self.view)
        
        characterPosX = recognizer.view!.center.x + translation.x
        characterPosY = recognizer.view!.center.y + translation.y
    }
    
    // Gesture: Pinch (to scale)
    @IBOutlet var gesturePinchCharacter: UIPinchGestureRecognizer!
    @IBAction func handleGesturePinchCharacter(recognizer: UIPinchGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformScale(recognizer.view!.transform, recognizer.scale, recognizer.scale)
        
        characterScale = recognizer.scale
        
        recognizer.scale = 1
    }
    
    // Gesture: Rotate
    @IBOutlet var gestureRotateCharacter: UIRotationGestureRecognizer!
    @IBAction func handleGestureRotateCharacter(recognizer: UIRotationGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformRotate(recognizer.view!.transform, recognizer.rotation)
        
        characterRotation = recognizer.rotation
        
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
        self.navigationController.setToolbarHidden(false, animated: false)
        self.displayPhoto()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController.setToolbarHidden(false, animated: false)
        self.becomeFirstResponder()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent!) {
        if(event.subtype == UIEventSubtype.MotionShake) {
            var character = UIImage(named: "head_" + String(randomInt(1, max: characterCount)))
            imgCharacter1.image = character
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Optional method implementations
    
    // Implement gesture delegate recognizer optional function to allow the user to perform multiple gesturesx
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }
}
