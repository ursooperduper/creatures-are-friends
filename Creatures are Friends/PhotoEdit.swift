//
//  PhotoEdit.swift
//  Creatures are Friends
//
//  Created by Sarah Kuehnle on 9/11/14.
//  Copyright (c) 2014 Sarah Kuehnle. All rights reserved.
//

import UIKit
import Photos
import CoreImage
import CoreGraphics

class PhotoEdit: UIViewController, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // Number of character images in the library
    let characterCount = 20
    
    // Photos Framework
    var assetCollection: PHAssetCollection!
    var photos: PHFetchResult!
    var index: Int!
    
    // Information about the character
    var characterInfo = [ String: CGFloat]()
    var currScale: CGFloat = 1
    var currRotation: CGFloat = 0
    var characterPos: CGPoint = CGPointZero
    
    var nextAction: String!
    var imageToEdit: UIImage!

    @IBOutlet var imgContainer: UIView! // The View that contains the photo and character
    @IBOutlet var photoImg: UIImageView! // The main photo
    @IBOutlet var characterImg: UIImageView! // The character head

    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let picker = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
            self.presentViewController(picker, animated: true, completion: nil)
        } else {
            // There is no camera available
            let alert = UIAlertController(title: "Error", message: "There is no camera available.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {(alertAction) in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // Creates a new photo out of the combined character and photo images
    func getCombinedImage(topImg: UIImage, bottomImg: UIImage) -> UIImage {
        
        // Create CIImage versions of the top & bottom images
        let fgImg = CIImage(image: topImg)
        let bgImg = CIImage(image: bottomImg)
        
        // Define the affine transformations
        let makeRotation = CGAffineTransformMakeRotation(-(characterInfo["rotation"]!))
        
        // Dividing by 2 makes the head appear correctly on iPhone 5s. Need to test on other devices.
        let makeScale = CGAffineTransformMakeScale((characterInfo["scale"])!/2, (characterInfo["scale"])!/2)
        
        // Create an affine transformation matrix
        let affineConcat = CGAffineTransformConcat(makeScale, makeRotation)
        
        // Define the context
        let affineContext = CIContext(options: nil)
        
        // Create the affine filter
        let affineFilter: CIFilter = CIFilter(name: "CIAffineTransform")
        affineFilter.setValue(fgImg, forKey: "inputImage")
        affineFilter.setValue(NSValue(CGAffineTransform: affineConcat), forKey: "inputTransform")
                
        // Grab the resulting image data
        let affineResult = affineFilter.valueForKey("outputImage") as CIImage
        
        // Define the size of the final image, this is the size of the photo
        let photoSize = CGSizeMake(bottomImg.size.width, bottomImg.size.height)
        
        // Begin the image context
        UIGraphicsBeginImageContext(photoSize)
        
        // Add the photo to the context
        bottomImg.drawInRect(CGRectMake(0, 0, photoSize.width, photoSize.height))
        
        // Set up the details for the new character image
        let newFgImg = UIImage(CIImage: affineResult)
        let newFgImgWidth = newFgImg?.size.width
        let newFgImgHeight = newFgImg?.size.height
        
        newFgImg?.drawInRect(CGRectMake(characterInfo["xPos"]!, characterInfo["yPos"]!, newFgImgWidth!, newFgImgHeight!), blendMode: kCGBlendModeNormal, alpha: 1.0)
        
        // Grab the graphic from the image context
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context
        UIGraphicsEndImageContext()
        
        return newImage
    }

    // Returns a random integer between two specified numbers
    func randomInt(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }

    // Retrieves an image using PHImageManager, the target size is of the screen dimensions.
    func displayPhoto() {
        if nextAction == "takePicture" {
            self.photoImg.image = imageToEdit
        } else {
            let imageManager = PHImageManager.defaultManager()
            let optionsForImage = PHImageRequestOptions()
            optionsForImage.resizeMode = .Exact
            optionsForImage.synchronous = true
            
            let id = imageManager.requestImageForAsset(self.photos[self.index] as PHAsset, targetSize: CGSize(width: imgContainer.bounds.width, height: imgContainer.bounds.height), contentMode: .AspectFill, options: optionsForImage, resultHandler: {(result, info) in
                self.photoImg.image = result
            })
        }
    }

    // Adds the new photo to the Creatures are Friends library
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

    
    // Cancel button
    @IBAction func btnCancel(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // Export/save button
    @IBAction func btnExport(sender: AnyObject) {
        characterInfo["xPos"] = characterImg.frame.origin.x
        characterInfo["yPos"] = characterImg.frame.origin.y
        characterInfo["scale"] = currScale
        characterInfo["rotation"] = currRotation

        let imageToSave = getCombinedImage(self.characterImg.image!, bottomImg: self.photoImg.image!)
        addNewAssetWithImage(imageToSave, toAlbum: self.assetCollection)

        self.navigationController?.popToRootViewControllerAnimated(true)
    }


    // Gesture: Double Tap
    @IBOutlet var gestureDoubleTap: UITapGestureRecognizer!
    @IBAction func handleGestureDoubleTap(recognizer: UITapGestureRecognizer) {
        
        let location = recognizer.locationInView(self.view)
        characterImg.hidden = false
        characterImg.center = location

        // Get a random character head
        var character = UIImage(named: "head_" + String(randomInt(1, max: characterCount)))
        characterImg.image = character
    }

    // Gesture: Pan
    // Allow the user to drag the character around the screen.
    @IBOutlet var gesturePanCharacter: UIPanGestureRecognizer!
    @IBAction func handleGesturePanCharacter(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x,
            y:recognizer.view!.center.y + translation.y)
        recognizer.setTranslation(CGPointZero, inView: self.view)
    }
    
    // Gesture: Pinch (to scale)
    @IBOutlet var gesturePinchCharacter: UIPinchGestureRecognizer!
    @IBAction func handleGesturePinchCharacter(recognizer: UIPinchGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformScale(recognizer.view!.transform, recognizer.scale, recognizer.scale)
        currScale *= recognizer.scale
        recognizer.scale = 1
    }

    // Gesture: Rotate
    @IBOutlet var gestureRotateCharacter: UIRotationGestureRecognizer!
    @IBAction func handleGestureRotateCharacter(recognizer: UIRotationGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformRotate(recognizer.view!.transform, recognizer.rotation)
        currRotation += recognizer.rotation
        recognizer.rotation = 0
    }

    // Controller override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create instances of the gesture recognizers
        view.addGestureRecognizer(gestureDoubleTap)
        characterImg.addGestureRecognizer(gesturePanCharacter)
        characterImg.addGestureRecognizer(gesturePinchCharacter)
        characterImg.addGestureRecognizer(gestureRotateCharacter)
        
        navigationController?.navigationBarHidden = false
        navigationController?.toolbarHidden = false
        
        println("in viewDidLoad(), the next action is \(nextAction)")
        
        switch nextAction {
            case "takePicture":
                openCamera()
            case "choosePhoto":
                displayPhoto()
            case "viewPhotos":
                displayPhoto()
        default:
           println("loading a case we're not expecting in the Edit controller.")
        }
        
//        if nextAction == "takePicture" {
//            openCamera()
//        }
    }

    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setToolbarHidden(false, animated: false)
        
        if nextAction != "takePicture" {
            self.displayPhoto()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: false)
        self.becomeFirstResponder()
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    // When the camera is shaken, change the character image
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if(event.subtype == UIEventSubtype.MotionShake) {
            var character = UIImage(named: "head_" + String(randomInt(1, max: characterCount)))
            characterImg.image = character
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // Implement gesture delegate recognizer optional function to allow the user to perform multiple gestures
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        imageToEdit = info[UIImagePickerControllerOriginalImage] as UIImage
        //        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        displayPhoto()
    }
}
