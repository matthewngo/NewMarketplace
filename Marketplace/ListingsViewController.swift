// listings
//  ListingsViewController.swift
//  Marketplace
//
//  Created by Matthew Ngo on 12/3/17.
//  Copyright © 2017 Matthew Ngo. All rights reserved.
//
import Firebase
import UIKit

class ListingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var ref: DatabaseReference?
    var itemCount: Int = 0
    var items: [String:Any]?
    var descriptions: [String:Any]?
    var selectedItem: NSDictionary = [:]
    var bookFilter: Bool = false
    var clothesFilter: Bool = false
    var furnFilter: Bool = false
    var techFilter: Bool = false
    var ticketFilter: Bool = false
    var otherFilter: Bool = false
    var activeFilters: [String] = []
    
    // If using filters
    var userItems: [String: Any] = [:]
    
    @IBAction func addFilter(_ sender: UIButton) {
        if (sender.backgroundColor == UIColor(red: 0.2941, green: 0.1804, blue: 0.5137, alpha: 1.0)) {
            sender.backgroundColor = UIColor(hue: 0.5639, saturation: 0.07, brightness: 0.65, alpha: 1.0)
            let title = sender.titleLabel?.text
            if title == "Books" {
                bookFilter = false
            } else if title == "Clothing" {
                clothesFilter = false
            } else if title == "Furniture" {
                furnFilter = false
            } else if title == "Tech" {
                techFilter = false
            } else if title == "Tickets" {
                ticketFilter = false
            } else if title == "Other" {
                otherFilter = false
            }
        } else {
            sender.backgroundColor = UIColor(red: 0.2941, green: 0.1804, blue: 0.5137, alpha: 1.0)
            let title = sender.titleLabel?.text
            if title == "Books" {
                bookFilter = true
            } else if title == "Clothing" {
                clothesFilter = true
            } else if title == "Furniture" {
                furnFilter = true
            } else if title == "Tech" {
                techFilter = true
            } else if title == "Tickets" {
                ticketFilter = true
            } else if title == "Other" {
                otherFilter = true
            }
        }
        var newFilters: [String] = []
        if bookFilter {
            newFilters.append("Books")
        }
        if clothesFilter {
            newFilters.append("Clothes")
        }
        if furnFilter {
            newFilters.append("Furniture")
        }
        if techFilter {
            newFilters.append("Technology")
        }
        if ticketFilter {
            newFilters.append("Tickets")
        }
        if otherFilter {
            newFilters.append("Other")
        }
        activeFilters = newFilters
        print(activeFilters)
        viewDidLoad()
        
        //        DispatchQueue.main.async{
        //            self.tableView.reloadData()
        //
        //        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("reloading")
        ref = Database.database().reference()
        ref?.observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() { return } // not necessary
            //print(snapshot)
            if let userName = snapshot.value as? [String:Any] {
                self.items = userName["items"] as? [String: Any]
                //print(self.items!.count)
                //                if(self.items == nil) {
                //                    self.itemCount = 0
                //                } else {
                //                    self.itemCount = self.items!.count
                //                    for key in self.items!.keys {
                //                        self.descriptions = self.items![key] as? [String:Any]
                //                    }
                //                }
                if (self.items == nil) {
                    self.itemCount = 0
                } else {
                    if (self.activeFilters.count == 0) {
                        self.itemCount = self.items!.count
                        for key in self.items!.keys {
                            self.descriptions = self.items![key] as? [String:Any]
                        }
                        //print(self.items)
                        print("no filter")
                    } else {
                        self.items = userName["items"] as? [String: Any]
                        self.userItems.removeAll()
                        // Looping through all the items
                        for (key, value) in self.items! {
                            let category = value as? [String:Any]
                            let c = category!["category"]
                            // Checks if the item contains the category in the activeFilters
                            if let i = self.activeFilters.index(of: c as! String) {
                                // appends them to user items
                                self.userItems[key] = value
                            }
                        }
                }
                    self.items = self.userItems
                    self.itemCount = self.items!.count
                    print("the filtered items are: \(String(describing: self.items))")
                    
                }
            }
            
            self.tableView.reloadData()
            // can also use
            // snapshot.childSnapshotForPath("full_name").value as! String
        })
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    
    // Workaround for ViewDidLoad after TableView
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemCount
    }
    
    
    @IBAction func unwindToListings(segue:UIStoryboardSegue) {
        NSLog("Listings")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        var iter = items!.keys.makeIterator()
        var next:String = ""
        
        for _ in 0 ... indexPath.row {
            next = iter.next()!
        }
        descriptions = self.items![next] as? [String:Any]
        //print(descriptions!["title"]! as? String)
        cell.textLabel!.text = descriptions!["title"]! as? String
        let details: String = (descriptions!["price"]! as? String)!
        cell.detailTextLabel?.text = "$\(details)"
        //cell.imageView?.image = image[indexPath.row]
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getItem(path:Int) -> NSDictionary {
        var count = 0
        var dictionary: NSDictionary = [:]
        for (key, info) in self.items! {
            if (count == path) {
                return info as! NSDictionary
            } else {
                count = count + 1
            }
        }
        return [:]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "PopoverSegue") {
            //print(table)
            let popover = segue.destination
            popover.modalPresentationStyle = UIModalPresentationStyle.popover
            popover.popoverPresentationController?.delegate = self
            
        }
        if (segue.identifier == "itemView") {
            let controller = segue.destination as! ItemViewController
            let currentPath = self.tableView.indexPathForSelectedRow!
            
            // self.items!.forEach { print($1) }
            selectedItem = getItem(path:currentPath[1])
            
            controller.itemDescription = selectedItem
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "itemView", sender:self)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
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

