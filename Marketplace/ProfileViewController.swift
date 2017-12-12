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
    
    var aboutData = [String]()
    var database = [String:Any]()
    var items: [String:Any]?
    var descriptions: [String:Any]?
    var itemCount: Int = 0
    var currentUser: String = ""
    var ref:DatabaseReference?
    var userItems: [String: Any] = [:]
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var classYear: UILabel!
    @IBOutlet weak var about: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        ref?.observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() { return }
        
            if let userName = snapshot.value as? [String:Any] {
                let email = userName["currentUser"] as? [String:Any]
                self.currentUser = (email!["email"] as? String)!
                self.items = userName["items"] as? [String: Any]
                self.itemCount = self.items!.count
                for key in self.items!.keys {
                    self.descriptions = self.items![key] as? [String:Any]
                }
                
                for (key, value) in self.items! {
                    var values = value as? [String:Any]
                    let email = values!["email"]
                    if (email as! String == self.currentUser) {
                        self.userItems[key] = value
                    }
                }
            // Do any additional setup after loading the view.
            }
        })
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

