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
    @IBOutlet weak var tableView: UITableView!
    
    
    var allReviews: [String:Any]?
    
    var reviewCount: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        seller = appDelegate.globalEmail
        calcAvg()
        tableView.delegate = self
        tableView.dataSource = self
        ref = Database.database().reference().child("profiles")
        ref = ref?.child(self.seller!)
        ref?.observeSingleEvent(of: .value, with: { (snapshot) in
            let itemReviews = snapshot.value as? NSDictionary
                self.allReviews = (itemReviews!["reviews"] as? [String: Any])
            if (self.allReviews != nil) {
                self.reviewCount = self.allReviews!.count
                self.tableView.reloadData()
            }
        })
        tableView.delegate = self
        tableView.dataSource = self
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
            if (value != nil) {
                for (key, value) in value! {
                    let id = value as! [String:Any]
                    let strRating = id["rating"] as! String
                    avg += Double(strRating)!
                }
                avg = avg / Double(value!.count)
                self.avgRating.text = "\(avg)"
                Database.database().reference().child("profiles").child(self.seller!).child("avgRating").setValue(avg)
            } else {
                self.avgRating.text = "No Reviews Yet"
            }
        }) { (error) in
            //print(error.localizedDescription)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reviewCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        var iter = self.allReviews!.keys.makeIterator()
        var next:String = ""
        for _ in 0 ... indexPath.row {
            next = iter.next()!
        }
        let descriptions = self.allReviews![next] as? [String:Any]
        let product = descriptions!["product"]! as? String
        let comment =  descriptions!["comment"]! as? String
        let rating =  descriptions!["rating"]! as? String
        let reviewer = descriptions!["reviewer"]! as? String
        cell.textLabel!.text = ("\(rating!) - Reviewer: \(reviewer!)")
        cell.detailTextLabel?.text = "(Product: \(product!) - \(comment!))"
        
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
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

