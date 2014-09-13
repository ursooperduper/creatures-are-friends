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
    }
    
    @IBOutlet var gestureDoubleTap: UITapGestureRecognizer!
    @IBAction func handleGestureDoubleTap(recognizer: UITapGestureRecognizer) {
        var location = recognizer.locationInView(self.view)
        imgLocationSet = location
        
        imgCharacter1.hidden = false
        imgCharacter1.center = location
        println("IMAGE LOCATION: \(location)")
        
        var character = UIImage(named: "head_" + String(randomInt(1, max: 20)))
        imgCharacter1.image = character
        
        imgCharacter1.removeGestureRecognizer(gestureDoubleTap)
    }

    // Allow the user to drag the character around the screen.
    @IBOutlet var gesturePanCharacter: UIPanGestureRecognizer!
    @IBAction func handleGesturePanCharacter(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x,
            y:recognizer.view!.center.y + translation.y)
        recognizer.setTranslation(CGPointZero, inView: self.view)
    }
    
    // All the user to pinch the character to scale and size it
    @IBOutlet var gesturePinchCharacter: UIPinchGestureRecognizer!
    @IBAction func handleGesturePinchCharacter(recognizer: UIPinchGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformScale(recognizer.view!.transform, recognizer.scale, recognizer.scale)
        recognizer.scale = 1
    }
    
    // Allow the user to rotate the character
    @IBOutlet var gestureRotateCharacter: UIRotationGestureRecognizer!
    @IBAction func handleGestureRotateCharacter(recognizer: UIRotationGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformRotate(recognizer.view!.transform, recognizer.rotation)
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
        var id = imageManager.requestImageForAsset(self.photos[self.index] as PHAsset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFit, options: nil, resultHandler: {(result, info) in
            self.imgView.image = result
        })
    }
    
    // Implement gesture delegate recognizer optional function to allow the user to perform multiple gesturesx
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }
}
