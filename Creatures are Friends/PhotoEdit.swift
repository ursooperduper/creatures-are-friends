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



class PhotoEdit: UIViewController, UIGestureRecognizerDelegate {

    let characterCount = 20
    var assetCollection: PHAssetCollection!
    var photos: PHFetchResult!
    var index: Int!
    var imgLocationSet: CGPoint!
    var totalScale: CGFloat = 1
    var totalRotation: CGFloat = 0
    var charLocation: CGPoint = CGPointZero
    var characterImagePosX: CGFloat!
    var characterImagePosY: CGFloat!

    @IBOutlet var imgView: UIImageView!
    @IBOutlet var characterImage: UIImageView!
    @IBOutlet var viewImage: UIView!

    // Creates a composite of the character head and photo
    func getComposite(topImg: UIImage, bottomImg: UIImage) -> UIImage {
        
        

        
        

        
        
        // Create CIImage versions of the top and bottom images
        var fgImg = CIImage(image: topImg)
        var bgImg = CIImage(image: bottomImg)
        
//        var makePhotoRotation = CGAffineTransformMakeRotation(-CGFloat(M_PI_2))
//        var makePhotoScale = CGAffineTransformMakeScale(1.0, 1.0)
//        var makePhotoPosition = CGAffineTransformMakeTranslation(imgView.frame.origin.x, imgView.frame.origin.y)
//        var affineConcatPhoto = CGAffineTransformConcat(makePhotoRotation, makePhotoScale)
//        var affineConcatPhoto2 = CGAffineTransformConcat(affineConcatPhoto, makePhotoPosition)
//        
//        var photoContext = CIContext(options: nil)
//        var photoAffineFilter = CIFilter(name: "CIAffineTransform")
//        photoAffineFilter.setValue(bgImg, forKey: "inputImage")
//        photoAffineFilter.setValue(NSValue(CGAffineTransform: affineConcatPhoto2), forKey: "inputTransform")
//        var photoResult = photoAffineFilter.valueForKey("outputImage") as CIImage
        
        // Define affine transformations
        var makeCharacterRotation = CGAffineTransformMakeRotation(-totalRotation)
        // Dividing by 2 makes the head appear correctly on iPhone 5s. Need to test on other devices.
        var makeCharacterScale = CGAffineTransformMakeScale(totalScale/2, totalScale/2)
//        var makeCharacterTranslation = CGAffineTransformMakeTranslation(imgLocationSet.x + charLocation.x, imgLocationSet.y + charLocation.y)
        
//        var makeCharacterTranslation = CGAffineTransformMakeTranslation(charLocation.x, charLocation.y)
//        var makeCharacterTranslation = CGAffineTransformMakeTranslation(-500, -500)
        
        // Create an affine transformation matrix
        var affineConcatCharacter1 = CGAffineTransformConcat(makeCharacterScale, makeCharacterRotation)
//        var affineConcatCharacter2 = CGAffineTransformConcat(affineConcatCharacter1, makeCharacterTranslation)
        
        // Define the context
        var affineContext = CIContext(options: nil)
        
        // CIAttributeTypeTransform
        var affineFilter: CIFilter = CIFilter(name: "CIAffineTransform")
        affineFilter.setValue(fgImg, forKey: "inputImage")
        affineFilter.setValue(NSValue(CGAffineTransform: affineConcatCharacter1), forKey: "inputTransform")
        
        var affineResult = affineFilter.valueForKey("outputImage") as CIImage
        
//        println("Character Affine SIZE: \(affineResult.extent())")
//        println("Photo Affine SIZE: \(photoResult.extent())")
//        
//        // create a context, this will store the image
//        var compContext: CIContext = CIContext(options: nil)
//        
//        var compFilter: CIFilter = CIFilter(name: "CISourceOverCompositing")
//        compFilter.setValue(affineResult, forKey: "inputImage")
//        compFilter.setValue(photoResult, forKey: "inputBackgroundImage")
//        var compResult = compFilter.valueForKey("outputImage") as CIImage
//        
//        // Get the size of the return image
//        var extent = compResult.extent()
////        var extent = bgImg.extent()
//        println("result of filter size: \(extent)")
//        var renderedImage = compContext.createCGImage(compResult, fromRect: extent)
//        var finalImage = UIImage(CGImage: renderedImage)
//        println("finalImage size: \(finalImage?.size)")
//        
        
        var testSize = CGSizeMake(bottomImg.size.width, bottomImg.size.height)
        UIGraphicsBeginImageContext(testSize)
        
        bottomImg.drawInRect(CGRectMake(0, 0, testSize.width, testSize.height))
        
        var newTop = UIImage(CIImage: affineResult)
        
        var newTopWidth = newTop?.size.width
        var newTopHeight = newTop?.size.height
        
        println("NEW CHAR WIDTH: \(newTopWidth)")
        println("NEW CHAR HEIGHT: \(newTopHeight)")
        
        newTop?.drawInRect(CGRectMake(characterImagePosX, characterImagePosY, newTopWidth!, newTopHeight!), blendMode: kCGBlendModeNormal, alpha: 1.0)
        
        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
//        var imageData = UIImagePNGRepresentation(newImage)
        
        //        var newSize = CGSizeMake(bottomImage.size.width, bottomImage.size.height)
        //        UIGraphicsBeginImageContext( newSize )
        //
        //        bottomImage.drawInRect(CGRectMake(0,0,newSize.width,newSize.height))
        //
        //        // decrease top image to 36x36
        //        imageTop.drawInRect(CGRectMake(18,18,36,36), blendMode:kCGBlendModeNormal, alpha:1.0)
        //
        //        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        //        var imageData = UIImagePNGRepresentation(newImage)
        

//        return finalImage!
        return newImage
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
        optionsForImage.synchronous = true
//        optionsForImage.deliveryMode = .HighQualityFormat
        
//        PHImageManagerMaximumSize
        // CGSize(width: viewImage.bounds.width, height: viewImage.bounds.height)
        var id = imageManager.requestImageForAsset(self.photos[self.index] as PHAsset, targetSize: CGSize(width: viewImage.bounds.width, height: viewImage.bounds.height), contentMode: .AspectFit, options: optionsForImage, resultHandler: {(result, info) in
            self.imgView.image = result
            

            // This is the size we want for the output image
            println("In view image size: \(self.imgView.image?.size)")
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

//        println("THE TRANSLATIONS ON THE CHARACTER ARE:")
//        println("CHAR ACTUAL SIZE?: \(characterImage.image?.size)")
//        println("CHAR IMG VIEW SIZE?: \(characterImage.bounds)")
//        println("SCALE: \(totalScale)")
//        println("ROTATION: \(totalRotation)")
//        println("LOCATION: \(charLocation)")

        // -- Approach 1: Turn UIVIew into Image
        //let imageToSave: UIImage = getUIImageFromView(viewImage)
        //
        // -- Approach 2: Composite Filter
        characterImagePosX = characterImage.frame.origin.x
        characterImagePosY = characterImage.frame.origin.y

        
        let imageToSave: UIImage = getComposite(self.characterImage.image!, bottomImg: self.imgView.image!)
        addNewAssetWithImage(imageToSave, toAlbum: self.assetCollection)

        self.navigationController?.popToRootViewControllerAnimated(true)
        
        
        
//        println("CHARACTER HEAD, WHAT IS YOUR X POSITION? \(characterImage.frame.origin.x)")
//        println("CHARACTER HEAD, WHAT IS YOUR Y POSITION? \(characterImage.frame.origin.y)")
//        
        
//        println("ORIENTATION: \(self.imgView.image?.imageOrientation.rawValue)")
//        println("SCALE FACTOR: \(self.imgView.image?.scale)")
//        println("SIZE: \(self.imgView.image?.size)")
//        println("ALIGNMENT RECT INSETS: \(self.imgView.image?.alignmentRectInsets)")
    }

    // ** GESTURE **
    // Gesture: Double Tap
    @IBOutlet var gestureDoubleTap: UITapGestureRecognizer!
    @IBAction func handleGestureDoubleTap(recognizer: UITapGestureRecognizer) {
        var location = recognizer.locationInView(self.view)
        imgLocationSet = location
        characterImage.hidden = false
        characterImage.center = location

        // Get a random character head
        var character = UIImage(named: "head_" + String(randomInt(1, max: characterCount)))
        characterImage.image = character
        println("Character Image added: SIZE: \(characterImage.bounds.size)")
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

//        println("X: \(charLocation.x) -- Y: \(charLocation.y)")

        recognizer.setTranslation(CGPointZero, inView: self.view)
    }

    // Gesture: Pinch (to scale)
    @IBOutlet var gesturePinchCharacter: UIPinchGestureRecognizer!
    @IBAction func handleGesturePinchCharacter(recognizer: UIPinchGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformScale(recognizer.view!.transform, recognizer.scale, recognizer.scale)
        totalScale *= recognizer.scale
//        println("Total Scale: \(totalScale)")

        recognizer.scale = 1
    }

    // Gesture: Rotate
    @IBOutlet var gestureRotateCharacter: UIRotationGestureRecognizer!
    @IBAction func handleGestureRotateCharacter(recognizer: UIRotationGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformRotate(recognizer.view!.transform, recognizer.rotation)

        totalRotation += recognizer.rotation
//        println("Total Rotation: \(totalRotation)")

        recognizer.rotation = 0
    }

    // Controller override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(gestureDoubleTap)
        characterImage.addGestureRecognizer(gesturePanCharacter)
        characterImage.addGestureRecognizer(gesturePinchCharacter)
        characterImage.addGestureRecognizer(gestureRotateCharacter)
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
            characterImage.image = character
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
