//
//  Menu.swift
//  Creatures are Friends
//
//  Created by Sarah Kuehnle on 9/22/14.
//  Copyright (c) 2014 Sarah Kuehnle. All rights reserved.
//

import UIKit
import Photos

class Menu: UIViewController, UINavigationControllerDelegate {

    var doThisNext: String!
    
    var albumFound = false
    var assetCollection: PHAssetCollection!
    var photos: PHFetchResult!
//    var galleryLoaded = false
    
    @IBAction func btnCamera(sender: UIButton) {
        println("Take a picture")
        doThisNext = "takePicture"
    }
    
    @IBAction func btnChoosePic(sender: UIButton) {
        println("Choose a photo")
        doThisNext = "choosePicture"
    }
    
    @IBAction func btnViewPic(sender: UIButton) {
        println("View photos")
        doThisNext = "viewPictures"
    }
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        
        switch segue.identifier as String! {
        case "takePicture":
            let controller: PhotoEdit = segue.destinationViewController as PhotoEdit
            controller.nextAction = doThisNext
            controller.assetCollection = self.assetCollection
        case "choosePicture", "viewPictures":
            let controller: PhotoGallery = segue.destinationViewController as PhotoGallery
            controller.nextAction = doThisNext
            controller.assetCollection = self.assetCollection
        default:
            println("Preparing for a segue we're not tracking.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        
        // Check if the app photo folder exists. If it doesn't create it.
        let collection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        
        if collection.firstObject != nil {
            // Found the album
            self.albumFound = true
            self.assetCollection = collection.firstObject as PHAssetCollection
        } else {
            // Create the folder
            NSLog("\nFolder\"%@\" does not exist.\nCreating now...", albumName)
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(albumName)
                }, completionHandler: {(success, error) in
                    NSLog("Creation of folder -> %@", success ? "Success" : "Error")
                    self.albumFound = success ? true : false
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = true
        navigationController?.toolbarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
