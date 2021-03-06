//
//  ProfileViewController.swift
//  Marketplace
//
//  Created by iGuest on 12/4/17.
//  Copyright © 2017 Matthew Ngo. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var aboutData = [String]()
    var database = [String:Any]()
    var items: [String:Any]?
    var descriptions: [String:Any]?
    var itemCount: Int = 0
    var currentUser: String = ""
    var ref:DatabaseReference?
    var userItems: [String: Any] = [:]
    var profiles: [String:Any]?
    var allItems: [String:Any] = [:]
    var allIDs : [String:Any] = [:]
    var ID: [String] = []
    var personInformation: String = ""
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var classYear: UILabel!
    @IBOutlet weak var about: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var reviewButton: UIButton!
    
    @IBOutlet weak var editBtn: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        reviewButton.layer.cornerRadius = 7
        reviewButton.contentEdgeInsets = UIEdgeInsetsMake(6, 20, 6, 20) // top, left, bottom, right
        ref = Database.database().reference()
        if (self.personInformation == "" || self.personInformation == self.appDelegate.globalEmail) {
            self.reviewButton.isHidden = true
            self.currentUser = self.appDelegate.globalEmail
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        } else {
            self.reviewButton.isHidden = false
            self.currentUser = self.personInformation
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
            
        }
        ref?.observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() { return }
            if let userName = snapshot.value as? [String:Any] {
                if (userName["items"] != nil) {
                    self.items = userName["items"] as? [String: Any]
                    self.itemCount = self.items!.count
                    self.profiles = userName["profiles"] as? [String:Any]
                    for key in self.items!.keys {
                        self.descriptions = self.items![key] as? [String:Any]
                    }
                    // Search for the profile, set allItems to profile->, email->, items(key, value)
                    for (key, value) in self.profiles! {
                        if (key == self.currentUser) {
                            let value = value as? [String:Any]
                            self.allItems[key] = value
                            let hold = (self.allItems[self.currentUser] as? [String:Any])!
                            if (hold["items"] != nil) {
                            self.allIDs = hold["items"]! as! [String:Any]
                            self.ID = Array(self.allIDs.keys)
                            }
                        }
                    }
                    if (self.ID.count > 0) {
                        for (key, value) in self.items! {
                            if let i = self.ID.index(of: key) {
                                self.userItems[key] = value
                            }
                        }
                    }
                }  // Do any additional setup after loading the view.
            }
        })
        print(self.currentUser)
        ref?.child("profiles").child(self.currentUser).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            print(value)
            if snapshot.hasChild("profileURL") && value!["profileURL"] as? String != "" { // set with image user added
                let url = value!["profileURL"] as? String
                print(url)
                self.downloadImage(url: url!)
                self.profileImg.contentMode = .scaleAspectFill
            } else { // if no image, set with default profile image
                let origImage = UIImage(named: "profile_default")
                let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
                self.profileImg.image = tintedImage
                self.profileImg.tintColor = .white // making the profile image white instead of black
                //self.profileImg.image = UIImage(named: "profile_default")
            }
            if snapshot.hasChild("name") {
                if value!["name"] as? String != "" {
                    self.name.text = value!["name"] as? String
                } else {
                    self.name.text = "Name"
                }
            } else {
                self.name.text = "Name"
            }
            if snapshot.hasChild("classYear") {
                if value!["classYear"] as? String != "" {
                    self.classYear.text = value!["classYear"] as? String
                } else {
                    self.classYear.text = "Class Year"
                }
            } else {
                self.classYear.text = "Class Year"
            }
            if snapshot.hasChild("about") {
                if value!["about"] as? String != "" {
                    self.about.text = value!["about"] as? String
                } else {
                    self.about.text = "About"
                }
            } else {
                self.about.text = "About"
            }
        } ) { (error) in
            print(error.localizedDescription)
        }
        self.profileImg.layer.cornerRadius = self.profileImg.frame.size.width / 2;
        self.profileImg.clipsToBounds = true;
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    public func downloadImage(url: String) {
        let imgUrl = URL(string: url)
        DispatchQueue.main.async {
            do {
                let data = try Data(contentsOf: imgUrl!)
                DispatchQueue.global().sync {
                    self.profileImg.image = UIImage(data: data)
                }
            } catch  {
                // handle error
            }
        }
    }
    
    @IBAction func unwindToProfile(segue:UIStoryboardSegue) {
        NSLog("Profile")
        ref?.child("profiles").child(currentUser).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let finName = value!["name"] as? String
            let finClassYear = value!["classYear"] as? String
            let finAbout = value!["about"] as? String
            if snapshot.hasChild("profileURL") && value!["profileURL"] as? String != "" {
                let finUrl = value!["profileURL"] as? String
                self.downloadImage(url: finUrl!)
                self.profileImg.contentMode = .scaleAspectFill
            }
            if snapshot.hasChild("name") && finName != "" {
                self.name.text = finName
            } else {
                self.name.text = "Name"
            }
            if snapshot.hasChild("classYear") && finClassYear != "" {
                self.classYear.text = finClassYear
            } else {
                self.classYear.text = "Class Year"
            }
            if snapshot.hasChild("about") && finAbout != "" {
                self.about.text = finAbout
            } else {
                self.about.text = "About"
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        var iter = userItems.keys.makeIterator()
        var next:String = ""
        for _ in 0 ... indexPath.row {
            next = iter.next()!
        }
        descriptions = userItems[next] as? [String:Any]
        cell.textLabel!.text = descriptions!["title"]! as? String
        let details: String = (descriptions!["price"]! as? String)!
        cell.detailTextLabel?.text = "$\(details)"
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "reviewSegue") {
            let controller = segue.destination as! ReviewSellerTableViewController
            controller.seller = self.personInformation
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (self.personInformation == "" || self.personInformation == self.appDelegate.globalEmail)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let singleItem = self.ID[indexPath.row]
            // Remove node from the items in Firebase
            ref = Database.database().reference()
            ref?.child("profiles").child(self.appDelegate.globalEmail).child("items").child(singleItem).removeValue()
            // Remove node from profile -> items -> the item
            ref?.child("items").child(singleItem).removeValue()
            self.userItems.removeValue(forKey: singleItem) as! [String:Any]
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
        }
        self.tableView.reloadData()
        self.viewDidLoad()
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

