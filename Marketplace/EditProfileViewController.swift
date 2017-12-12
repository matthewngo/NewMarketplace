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
    
    var ref: DatabaseReference?
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var about: UITextField!
    @IBOutlet weak var classyear: UITextField!
    
    @IBAction func submit(_ sender: Any) {
        ref = Database.database().reference()
        let profiles = Database.database().reference(withPath: "profiles")
        if (name.text != "" && about.text != "" && classyear.text != "") {
            profiles.child("name").setValue(name.text)
            profiles.child("about").setValue(about.text)
            profiles.child("classyear").setValue(classyear.text)
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
