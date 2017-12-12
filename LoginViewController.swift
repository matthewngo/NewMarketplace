//
//  LoginViewController.swift
//  Marketplace
//
//  Created by Lauren Antilla on 12/1/17.
//  Copyright © 2017 Matthew Ngo. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    var ref: DatabaseReference?
    @IBOutlet weak var email: UITextField!
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        ref = Database.database().reference()
        let profilesRef = Database.database().reference(withPath: "profiles")
        let currentUserRef = Database.database().reference(withPath: "currentUser")
        if (email.text?.contains("@uw.edu"))! {
            let idx = email.text?.index(of: "@")
            profilesRef.child((email.text?.substring(to: idx!))!).child("email").setValue(email.text)
            //profilesRef.childByAutoId().child("email").setValue(email.text)
            currentUserRef.child("email").setValue(email.text)
            email.text = ""
            self.performSegue(withIdentifier: "loginSegue", sender: self)
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
