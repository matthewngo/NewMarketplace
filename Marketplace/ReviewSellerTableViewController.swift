//
//  ReviewSellerTableViewController.swift
//  Marketplace
//
//  Created by Lauren Antilla on 12/12/17.
//  Copyright © 2017 Matthew Ngo. All rights reserved.
//

import UIKit
import Firebase

class ReviewSellerTableViewController: UITableViewController {
    var seller: String?
    var ref:DatabaseReference?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var sellerName: UILabel!
    @IBOutlet weak var itemField: UITextField!
    @IBOutlet weak var ratingField: UITextField!
    @IBOutlet weak var commentField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sellerName.text = seller!
    }

    @IBAction func submitBtnPressed(_ sender: Any) {
        if(self.appDelegate.globalEmail != self.seller) {
            ref = Database.database().reference().child("profiles")
            ref = ref?.child(self.seller!)
            ref?.observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let reviewsRef = self.ref?.child("reviews")
                let reviewRef = reviewsRef?.childByAutoId()
                let rating = self.ratingField.text
                reviewRef?.child("rating").setValue(rating)
                let comment = self.commentField.text
                reviewRef?.child("comment").setValue(comment)
                let product = self.itemField.text
                reviewRef?.child("product").setValue(product)
                let reviewer = self.appDelegate.globalEmail
                reviewRef?.child("reviewer").setValue(reviewer)
            } ) { (error) in
                //print(error.localizedDescription)
            }
        } else {
            print("You can't review yourself!")
        }
 
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (self.appDelegate.globalEmail != self.seller) {
            if (segue.identifier == "returnProfileSegue") {
                ref = Database.database().reference().child("profiles")
                ref = ref?.child(self.seller!)
                ref?.observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    let reviewsRef = self.ref?.child("reviews")
                    let reviewRef = reviewsRef?.childByAutoId()
                    let rating = self.ratingField.text
                    reviewRef?.child("rating").setValue(rating)
                    let comment = self.commentField.text
                    reviewRef?.child("comment").setValue(comment)
                    let product = self.itemField.text
                    reviewRef?.child("product").setValue(product)
                    let reviewer = self.appDelegate.globalEmail
                    reviewRef?.child("reviewer").setValue(reviewer)
                } ) { (error) in
                    print(error.localizedDescription)
                }
            }
        } else {
            print("You can't review yourself")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
