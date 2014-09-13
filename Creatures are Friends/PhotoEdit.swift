//
//  PhotoEdit.swift
//  Creatures are Friends
//
//  Created by Sarah Kuehnle on 9/11/14.
//  Copyright (c) 2014 Sarah Kuehnle. All rights reserved.
//

import UIKit
import Photos

class PhotoEdit: UIViewController {
    
    var assetCollection: PHAssetCollection!
    var photos: PHFetchResult!
    var index: Int = 0
    
    @IBOutlet var imgView: UIImageView!
    
    @IBOutlet var imgCharacter1: UIImageView!
    
    
    // Button Actions
    @IBAction func btnCancel(sender: AnyObject) {
        println("Cancel")
        self.navigationController.popToRootViewControllerAnimated(true)
    }
    @IBAction func btnExport(sender: AnyObject) {
        println("Export")
        // Save and share should probably go here
    }
    @IBAction func btnDelete(sender: AnyObject) {
        println("Trash")
        
        let alert = UIAlertController(title: "Delete Image", message: "Are you sure you want to delete this image?", preferredStyle: .Alert)
        
        // Action: Yes -- User wants to delete the photo
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {(alertAction) in
            // Delete the photo
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let request = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
                request.removeAssets([self.photos[self.index]])
                }, completionHandler: {(success, error) in
                    NSLog("\nDeleted image -. %@", (success ? "Success" : "Error!" ))
                    alert.dismissViewControllerAnimated(true, completion: nil)
                    
                    self.photos = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: nil)
                    if self.photos.count == 0 {
                        self.imgView.image == nil
                        println("No images left!")
                        //!! Pop to the root view controller
                    }
                    
                    // The user deleted the last photo, so set the index to the last photo now
                    if self.index >= self.photos.count {
                        self.index = self.photos.count - 1
                    }
                    self.displayPhoto()
            })
        }))
        
        // Action: No -- User doesn't want to delete the photo
        alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: {(alertAction) in
            // don't delete the photo
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //    @IBOutlet var gestureSwipeRight: UISwipeGestureRecognizer!
    //
    //    @IBAction func gestureShowCreature(recognizer: UISwipeGestureRecognizer) {
    //        println("Detected Right Swipe!")
    //
    //
    //        //var location = recognizer.locationInView(view)
    //
    //        imgCharacter1.hidden = false
    //
    //
    //    }
    
    @IBOutlet var gestureDoubleTap: UITapGestureRecognizer!
    @IBAction func handleGestureDoubleTap(recognizer: UITapGestureRecognizer) {
        var location = recognizer.locationInView(view)
        
        imgCharacter1.hidden = false
        imgCharacter1.center = location
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view.addGestureRecognizer(gestureSwipeRight)
        
        view.addGestureRecognizer(gestureDoubleTap)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController.hidesBarsOnSwipe = true
        self.displayPhoto()
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
}
