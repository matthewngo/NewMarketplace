//
//  AddItemViewController.swift
//  Marketplace
//
//  Created by Lauren Antilla on 12/1/17.
//  Copyright © 2017 Matthew Ngo. All rights reserved.
//

import UIKit
import Firebase

class AddItemViewController: UITableViewController {
    var ref: DatabaseReference?
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var bestOfferSwitch: UISwitch!
    @IBOutlet weak var descriptionField: UITextField!
    
    var itemCondition: String = "New"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitBtnPressed(_ sender: Any) {
        ref = Database.database().reference()
        let itemsRef = Database.database().reference(withPath: "items")
        let item = itemsRef.childByAutoId()
        var on = true
        if bestOfferSwitch.isOn {
            on = true
        } else {
            on = false
        }
        item.child("title").setValue(titleField.text)
        checkCondition()
        item.child("condition").setValue(itemCondition)
        item.child("conditionComment").setValue(commentField.text)
        item.child("price").setValue(price.text)
        item.child("bestOffer").setValue(on)
        item.child("description").setValue(descriptionField.text)
    }
    
    func checkCondition() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            itemCondition = "New"
        case 1:
            itemCondition = "Like New"
        case 2:
            itemCondition = "Used"
        case 3:
            itemCondition = "N/A"
        default:
            NSLog("Error")
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
