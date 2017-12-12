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
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var classYear: UILabel!
    @IBOutlet weak var about: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        ref?.observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() { return }
            self.currentUser = self.appDelegate.globalEmail
            if let userName = snapshot.value as? [String:Any] {
                self.items = userName["items"] as? [String: Any]
                self.itemCount = self.items!.count
                self.profiles = userName["profiles"] as? [String:Any]
                for key in self.items!.keys {
                    self.descriptions = self.items![key] as? [String:Any]
                }
                // Search for the profile, set allItems to profile->, email->, items(key, value)
                for (key, value) in self.profiles! {
                    if (key == self.currentUser) {
                        var value = value as? [String:Any]
                        self.allItems[key] = value
                        let hold = (self.allItems[self.appDelegate.globalEmail] as? [String:Any])!
                        self.allIDs = hold["items"]! as! [String:Any]
                        self.ID = Array(self.allIDs.keys)
                    }
                }
                
                for (key, value) in self.items! {
                    if let i = self.ID.index(of: key) {
                        self.userItems[key] = value
                    }
                }
                // Do any additional setup after loading the view.
            }
        })
        ref?.child("profiles").child(appDelegate.globalEmail).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            print(value)
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
        ref?.child("profiles").child(appDelegate.globalEmail).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            print(value)
            let finName = value!["name"] as? String
            let finClassYear = value!["classYear"] as? String
            let finAbout = value!["about"] as? String
            if finName != "" {
                self.name.text = finName
            }
            if finClassYear != "" {
                self.classYear.text = finClassYear
            }
            if finAbout != "" {
                self.about.text = finAbout
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
    
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "yourItemView", sender:self)
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

