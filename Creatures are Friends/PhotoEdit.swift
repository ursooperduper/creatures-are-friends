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
    
    func randomInt(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    // Button Actions
    @IBAction func btnCancel(sender: AnyObject) {
        self.navigationController.popToRootViewControllerAnimated(true)
    }
    @IBAction func btnExport(sender: AnyObject) {
        println("Save Image")
        // Save and share should probably go here
        var alert = UIAlertController(title: "Save", message: "Would you like to save this image?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {(alertAction) in
            
            // hide the character head
            self.imgCharacter1.hidden = true
            
            var currentBG: UIImage = self.imgView.image
            
            var dataFromImage: NSData = UIImagePNGRepresentation(currentBG) // returns image as jpeg
            
            var characterImg: NSData = UIImagePNGRepresentation(self.imgCharacter1.image)
            
            var beginImage = CIImage(data: dataFromImage)
            var context = CIContext(options: nil)
           
            var characterHead = CIImage(data: characterImg)
            
            var filter = CIFilter(name: "CISourceOverCompositing")
            
            filter.setDefaults()
            filter.setValue(characterHead, forKey: "inputImage")
            filter.setValue(beginImage, forKey: "inputBackgroundImage")
            
            var outputImage: CIImage = filter.valueForKey("outputImage") as CIImage
            
            var extent = characterHead.extent()
            
            var cgimg: CGImageRef = context.createCGImage(outputImage, fromRect: extent)
            
            var newImage = UIImage(CGImage: cgimg)
            
            self.imgView.image = newImage
            
            NSLog("\nView width: %@", self.view.bounds.width)
            NSLog("\nView height: %@", self.view.bounds.height)
            
            NSLog("\nCharacter height: %@", self.characterWidth)
            NSLog("\nCharacter width: %@", self.characterHeight)
            NSLog("\nCharacter XPos: %@", self.characterPosX)
            NSLog("\nCharacter YPos: %@", self.characterPosY)
//            NSLog("\nCharacter scale: %@", self.characterScale)
//            NSLog("\nCharacter rotation: %@", self.characterRotation)
            
            NSLog("\nNew image width: %@", newImage.size.width)
            NSLog("\nNew image height: %@", newImage.size.height)


            
            
            //alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: {(alertAction) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBOutlet var gestureDoubleTap: UITapGestureRecognizer!
    @IBAction func handleGestureDoubleTap(recognizer: UITapGestureRecognizer) {
        var location = recognizer.locationInView(self.view)
        imgLocationSet = location
        
        imgCharacter1.hidden = false
        imgCharacter1.center = location
        
        var character = UIImage(named: "head_" + String(randomInt(1, max: 20)))
        imgCharacter1.image = character
        
        imgCharacter1.removeGestureRecognizer(gestureDoubleTap)
        
        characterHeight = imgCharacter1.bounds.height
        characterWidth = imgCharacter1.bounds.width
    }

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
    
    // Allow the user to pinch the character to scale and size it
    @IBOutlet var gesturePinchCharacter: UIPinchGestureRecognizer!
    @IBAction func handleGesturePinchCharacter(recognizer: UIPinchGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformScale(recognizer.view!.transform, recognizer.scale, recognizer.scale)
        
        characterScale = recognizer.scale
        
        recognizer.scale = 1
    }
    
    // Allow the user to rotate the character
    @IBOutlet var gestureRotateCharacter: UIRotationGestureRecognizer!
    @IBAction func handleGestureRotateCharacter(recognizer: UIRotationGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformRotate(recognizer.view!.transform, recognizer.rotation)
        
        characterRotation = recognizer.rotation
        
        recognizer.rotation = 0
    }
    
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
    
    func displayPhoto() {
        let imageManager = PHImageManager.defaultManager()
        // commented out: targetSize: PHImageManagerMaximumSize in favor or square test
        var id = imageManager.requestImageForAsset(self.photos[self.index] as PHAsset, targetSize: CGSize(width: 300, height: 300), contentMode: .AspectFit, options: nil, resultHandler: {(result, info) in
            self.imgView.image = result
            
            NSLog("\nNew Image Width: %@", self.imgView.image.size.width)
            NSLog("\nNew Image Height: %@", self.imgView.image.size.height)
            NSLog("\nNew Image Scale: %@", self.imgView.image.scale)
            
        })
    }
    
    // Implement gesture delegate recognizer optional function to allow the user to perform multiple gesturesx
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }
}
