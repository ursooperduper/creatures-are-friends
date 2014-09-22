//
//  Menu.swift
//  Creatures are Friends
//
//  Created by Sarah Kuehnle on 9/22/14.
//  Copyright (c) 2014 Sarah Kuehnle. All rights reserved.
//

import UIKit

class Menu: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // ----------------------------- Button Actions -----------------------------
    
    @IBOutlet var btnCamera: UIImageView!
    @IBOutlet var btnChoosePic: UIImageView!
    @IBOutlet var btnViewCreatures: UIImageView!
    
    // ----------------------------- Gestures -----------------------------
    
    @IBOutlet var gestureTapCamera: UITapGestureRecognizer!
    @IBAction func handleTapCamera(sender: UITapGestureRecognizer) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            // Load the camera interface
            let picker = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
//            picker.allowsEditing = false
            
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
    
    @IBOutlet var gestureTapChoosePic: UITapGestureRecognizer!
    @IBAction func handleTapChoosePic(sender: UITapGestureRecognizer) {
        println("Choose a picture")
    }
    
    @IBOutlet var gestureTapViewPics: UITapGestureRecognizer!
    @IBAction func handleTapViewPics(sender: UITapGestureRecognizer) {
        println("View your creatures")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnCamera.addGestureRecognizer(gestureTapCamera)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        println("User wants to save the photo")
        
        let imageToSave: UIImage = info[UIImagePickerControllerOriginalImage] as UIImage
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
        
        
        // Instead of this, transition to the Photo Edit view with the photo taken in the editor
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
