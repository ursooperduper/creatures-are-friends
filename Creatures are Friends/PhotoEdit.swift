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
    var characterInfo = [ String: CGFloat]()
    var currScale: CGFloat = 1
    var currRotation: CGFloat = 0
    var characterPos: CGPoint = CGPointZero

    @IBOutlet var imgContainer: UIView!
    @IBOutlet var photoImg: UIImageView!
    @IBOutlet var characterImg: UIImageView!

    func formatCharacterForSaving(character: UIImage) -> UIImage {
        let rotation   = CGAffineTransformMakeRotation(-(characterInfo["rotation"]!))
        let scale = CGAffineTransformMakeScale((characterInfo["scale"])!/2, (characterInfo["scale"])!/2)
        let affineTransformationMatrix = CGAffineTransformConcat(rotation, scale)
        let context = CIContext(options: nil)
        let transformFilter = CIFilter(name: "CIAffineTransform")
        let characterData = CIImage(image: character)
        transformFilter.setValue(characterData, forKey: "inputImage")
        transformFilter.setValue(NSValue(CGAffineTransform: affineTransformationMatrix), forKey: "inputTransform")
        let filterResult = transformFilter.valueForKey("outputImage") as CIImage
        return UIImage(CIImage: filterResult)!
    }
    
    func getCombinedImage(character: UIImage, photo: UIImage) -> UIImage {
        let photoSize = CGSizeMake(photo.size.width, photo.size.height)
        UIGraphicsBeginImageContext(photoSize)
        photo.drawInRect(CGRectMake(0, 0, photoSize.width, photoSize.height))
        character.drawInRect(CGRectMake(characterInfo["xPos"]!, characterInfo["yPos"]!, character.size.width, character.size.height), blendMode: kCGBlendModeNormal, alpha: 1.0)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func randomInt(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }

    func displayPhoto() {
        let imageManager = PHImageManager.defaultManager()
        let optionsForImage = PHImageRequestOptions()
        optionsForImage.resizeMode = .Exact
        optionsForImage.synchronous = true

        let id = imageManager.requestImageForAsset(self.photos[self.index] as PHAsset, targetSize: CGSize(width: imgContainer.bounds.width, height: imgContainer.bounds.height), contentMode: .AspectFill, options: optionsForImage, resultHandler: {(result, info) in
            self.photoImg.image = result
        })
    }

    func addNewAssetWithImage(image: UIImage, toAlbum album:PHAssetCollection) {
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: album)
            let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
            albumChangeRequest.addAssets([assetPlaceholder])
            }, completionHandler: { success, error in
                NSLog("Finished adding asset. %@", (success ? "Success" : error))
        })
    }

    @IBAction func btnCancel(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    @IBAction func btnExport(sender: AnyObject) {
        characterInfo["xPos"] = characterImg.frame.origin.x
        characterInfo["yPos"] = characterImg.frame.origin.y
        characterInfo["scale"] = currScale
        characterInfo["rotation"] = currRotation
        
        let character = formatCharacterForSaving(self.characterImg.image!)
        let imageToSave = getCombinedImage(character, photo: self.photoImg.image!)
        addNewAssetWithImage(imageToSave, toAlbum: self.assetCollection)

        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    @IBOutlet var gestureDoubleTap: UITapGestureRecognizer!
    @IBAction func handleGestureDoubleTap(recognizer: UITapGestureRecognizer) {

        let location = recognizer.locationInView(self.view)
        characterImg.hidden = false
        characterImg.center = location

        // Get a random character head
        var character = UIImage(named: "head_" + String(randomInt(1, max: characterCount)))
        characterImg.image = character
    }

    @IBOutlet var gesturePanCharacter: UIPanGestureRecognizer!
    @IBAction func handleGesturePanCharacter(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x,
            y:recognizer.view!.center.y + translation.y)
        recognizer.setTranslation(CGPointZero, inView: self.view)
    }

    @IBOutlet var gesturePinchCharacter: UIPinchGestureRecognizer!
    @IBAction func handleGesturePinchCharacter(recognizer: UIPinchGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformScale(recognizer.view!.transform, recognizer.scale, recognizer.scale)
        currScale *= recognizer.scale
        recognizer.scale = 1
    }

    @IBOutlet var gestureRotateCharacter: UIRotationGestureRecognizer!
    @IBAction func handleGestureRotateCharacter(recognizer: UIRotationGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformRotate(recognizer.view!.transform, recognizer.rotation)
        currRotation += recognizer.rotation
        recognizer.rotation = 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(gestureDoubleTap)
        characterImg.addGestureRecognizer(gesturePanCharacter)
        characterImg.addGestureRecognizer(gesturePinchCharacter)
        characterImg.addGestureRecognizer(gestureRotateCharacter)
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
            characterImg.image = character
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }
}
