//
//  EditProfileViewController.swift
//  Marketplace
//
//  Created by iGuest on 12/9/17.
//  Copyright © 2017 Matthew Ngo. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var ref: DatabaseReference?
    
    @IBOutlet weak var profileImgBtn: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var classField: UITextField!
    @IBOutlet weak var aboutField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        // find all of the information for a specific profile
        ref?.child("profiles").child(appDelegate.globalEmail).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value!["name"] != nil { // user has edited info or entered name before
                self.nameField.text = value!["name"] as? String
            }
            if value!["classYear"] != nil { // user has edited info or entered class name before
                self.classField.text = value!["classYear"] as? String
            }
            if value!["about"] != nil { // user has edited info or entered about info before
                self.aboutField.text = value!["about"] as? String
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitBtnPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "profileSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if submit btn is pressed, save all of the profile information to firebase
        let name = nameField.text
        let classYear = classField.text
        let about = aboutField.text
        let userRef = ref?.child("profiles").child(appDelegate.globalEmail)
        userRef?.child("name").setValue(name)
        userRef?.child("classYear").setValue(classYear)
        userRef?.child("about").setValue(about)
        print(ref?.child("profiles").child(appDelegate.globalEmail).child("name"))
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
