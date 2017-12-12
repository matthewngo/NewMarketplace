//
//  EditProfileViewController.swift
//  Marketplace
//
//  Created by iGuest on 12/9/17.
//  Copyright © 2017 Matthew Ngo. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var ref: DatabaseReference?
    
    @IBOutlet weak var profileImgBtn: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var classField: UITextField!
    @IBOutlet weak var aboutField: UITextField!
    
    var downloadURL: URL?
    var finalUrl: String = ""
    var imgChanged: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        // find all of the information for a specific profile
        ref?.child("profiles").child(appDelegate.globalEmail).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value!["name"] as? String != "" { // user has edited info or entered name before
                self.nameField.text = value!["name"] as? String
            }
            if value!["classYear"] as? String != "" { // user has edited info or entered class name before
                self.classField.text = value!["classYear"] as? String
            }
            if value!["about"] as? String != "" { // user has edited info or entered about info before
                self.aboutField.text = value!["about"] as? String
            }
            if snapshot.hasChild("profileURL") && value!["profileURL"] as? String != "" { // user has added a profile image
                let url = value!["profileURL"] as? String
                self.downloadImage(url: url!)
            } else { // user has not added a profile image
                let origImage = UIImage(named: "profile_default")
                let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
                self.profileImgBtn.setImage(tintedImage, for: .normal)
                self.profileImgBtn.tintColor = .white // making default profile image white
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        // make image round
        //self.profileImgBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFit;
        self.profileImgBtn.layer.cornerRadius = self.profileImgBtn.frame.size.width / 2;
        self.profileImgBtn.clipsToBounds = true;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitBtnPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "profileSegue", sender: self)
    }
    
    public func downloadImage(url: String) {
        let imgUrl = URL(string: url)
        print(imgUrl)
        DispatchQueue.main.async {
            do {
                let data = try Data(contentsOf: imgUrl!)
                DispatchQueue.global().sync {
                    let img = UIImage(data: data)
                    self.profileImgBtn.setImage(img, for: UIControlState.normal)
                }
            } catch  {
                // handle error
            }
        }
    }
    
    @IBAction func imgBtnPressed(_ sender: Any) {
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            print("Photo Library is not available")
            return
        } else {
            let imgPicker = UIImagePickerController()
            imgPicker.delegate = (self as UIImagePickerControllerDelegate & UINavigationControllerDelegate)
            imgPicker.sourceType = .photoLibrary
            imgPicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            imgPicker.allowsEditing = false
            self.present(imgPicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let img = info[UIImagePickerControllerOriginalImage] {
            imgChanged = true
            profileImgBtn.setImage(img as? UIImage, for: UIControlState.normal)
            //profileImgBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        }
        picker.dismiss(animated: true, completion: nil)
        uploadImage()
    }
    
    func uploadImage() {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imgName = NSUUID().uuidString
        let imageData = UIImageJPEGRepresentation((profileImgBtn.imageView?.image)!, 0.1)
        let imageRef = storageRef.child("\(imgName).jpg")
        let uploadTask = imageRef.putData(imageData!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            self.downloadURL = metadata.downloadURL()!
            self.finalUrl = (self.downloadURL?.absoluteString)!
            print(self.downloadURL!)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if submit btn is pressed, save all of the profile information to firebase
        if segue.identifier == "profileSegue" {
            let name = nameField.text
            let classYear = classField.text
            let about = aboutField.text
            let userRef = ref?.child("profiles").child(appDelegate.globalEmail)
            userRef?.child("name").setValue(name)
            userRef?.child("classYear").setValue(classYear)
            userRef?.child("about").setValue(about)
            if imgChanged {
                userRef?.child("profileURL").setValue(finalUrl)
            }
            print(ref?.child("profiles").child(appDelegate.globalEmail).child("name"))
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
