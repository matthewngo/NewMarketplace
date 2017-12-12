//
//  ReviewsViewController.swift
//  Marketplace
//
//  Created by Lauren Antilla on 12/12/17.
//  Copyright © 2017 Matthew Ngo. All rights reserved.
//

import UIKit
import Firebase

class ReviewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var ref:DatabaseReference?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var avgRating: UILabel!
    var seller: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        seller = appDelegate.globalEmail
        calcAvg()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calcAvg() {
        var avg: Double = 0.0
        ref = Database.database().reference().child("profiles")
        ref = ref?.child(self.seller!).child("reviews")
        ref?.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            print(value)
            for (key, value) in value! {
                let id = value as! [String:Any]
                let strRating = id["rating"] as! String
                avg += Double(strRating)!
                print(avg)
            }
            print(avg)
            self.avgRating.text = "\(avg)"
        } ) { (error) in
            //print(error.localizedDescription)
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
