//
//  PhotoGallery
//  Creatures are Friends
//
//  Created by Sarah Kuehnle on 9/11/14.
//  Copyright (c) 2014 Sarah Kuehnle. All rights reserved.
//

import UIKit
import Photos

let reuseIdentifier = "photoCell"
let albumName = "Creatures are Friends"

class PhotoGallery: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var albumFound = false
    var assetCollection: PHAssetCollection!
    var photos: PHFetchResult!
    var galleryLoaded = false
    
    // ------------------------------ Button Actions ------------------------------
    @IBAction func btnCamera(sender: AnyObject) {
        // First, check to see if a camera is available
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            // Load the camera interface
            let picker: UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
            picker.allowsEditing = false
            // Show the camera interface
            self.presentViewController(picker, animated: true, completion: nil)
        } else {
            // There is no camera vailable
            let alert = UIAlertController(title: "Error", message: "There is no camera available.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {(alertAction) in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnPhotoAlbum(sender: AnyObject) {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBOutlet var collectionView: UICollectionView!
    
    // ---------------------------- Controller Methods ----------------------------
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
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.hidesBarsOnTap = false
        self.photos = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: nil)
        
        //!!Handle the case where no photos are loaded
        // Add a label that says, "No Photos", perhaps
    
        self.collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if segue.identifier as String! == "viewLargePhoto" {
            let controller: PhotoEdit = segue.destinationViewController as PhotoEdit
            let indexPath: NSIndexPath = self.collectionView.indexPathForCell(sender as UICollectionViewCell)!
            
            controller.index = indexPath.item
            controller.photos = self.photos
            controller.assetCollection = self.assetCollection
        }
    }


    // ------------------------- Supporting Functions for Classes -----------------
    // UICollectionViewDataSource methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count: Int = 0
        if self.photos != nil {
            count = self.photos.count
        }
        return count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: PhotoThumb = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as PhotoThumb

        // Modify the cell
        let asset: PHAsset = self.photos[indexPath.item] as PHAsset
        PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSize(width: 320, height: 459), contentMode: .AspectFill, options: nil, resultHandler: {(result, info) in
            
            cell.setThumbnailImage(result)
        })
        return cell
    }
    
    // UICollectionViewDelegateFlowLayout methods
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    // UIImagePickerControllerDelegate methods
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: NSDictionary) {
        let image = info.objectForKey(UIImagePickerControllerOriginalImage) as UIImage
        // let editedimage = info.objectForKey(UIImagePickerControllerEditedImage) as UIImage
        // imagePickerController.allowsEditing = YES;
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            let assetPlaceHolder = createAssetRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection, assets: self.photos)
            albumChangeRequest.addAssets([assetPlaceHolder])
            }, completionHandler: {(success, error) in
                NSLog("Adding image to Library -> %@", (success ? "Success" : "Error!"))
                picker.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}