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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "returnProfileSegue") {
            ref = Database.database().reference()
            ref?.child("profiles").child(sellerName).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let reviewsRef = ref.child("profiles").child(sellerName).child("reviews")
                let reviewRef = reviewsRef.childByAutoId()
                let rating = ratingField.text
                reviewRef.child("rating").setValue(rating)
                let comment = commentField.text
                reviewRef.child("comment").setValue(comment)
                let product = productField.text
                reviewRef.child("product").setValue(product)
                let reviewer = appDelegate.globalEmail
                reviewRef.child("reviewer").setValue(reviewer)
            } ) { (error) in
               print(error.localizedDescription)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
