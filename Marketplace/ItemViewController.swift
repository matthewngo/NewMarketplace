//
//  ItemViewController.swift
//  Marketplace
//
//  Created by iGuest on 12/8/17.
//  Copyright © 2017 Matthew Ngo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import MessageUI

class ItemViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    var id: String = ""
    var itemDescription: NSDictionary = [:]
    var ref: DatabaseReference?
    var sections = ["Condition", "Description", "Category"]
    
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var itemImg: UIImageView!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var fullTitle: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var bestOfferLabel: UILabel!
    @IBOutlet weak var sellerBtn: UIButton!
    @IBOutlet weak var sellerName: UIButton!
    
    var titleText: String?
    var priceText: String?
    var imgUrl: String = ""
    var bestOffer: Bool?
    var desc: String?
    var cat: String?
    var condition: String?
    var conComment: String?
    var sellerText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // having an id means that it is coming from the add item or profile pages
        if id != "" {
            print(id)
            ref = Database.database().reference()
            //print(ref?.child("items").child(id))
            // searching Firebase for item id and then getting all of the info for that item
            ref?.child("items").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                print("testing")
                let value = snapshot.value as? NSDictionary
                print(value)
                self.titleText = value!["title"] as? String
                self.priceText = value!["price"] as? String
                print(self.priceText)
                self.imgUrl = (value!["imageURL"] as? String)!
                self.bestOffer = value!["bestOffer"] as? Bool
                self.desc = value!["description"] as? String
                self.cat = value!["category"] as? String
                self.condition = value!["condition"] as? String
                self.conComment = value!["conditionComment"] as? String
                self.sellerText = value!["seller"] as? String
                self.addContent()
            }) { (error) in
                print(error.localizedDescription)
            }
        } else { // coming from item listings page
            titleText = itemDescription["title"] as? String
            self.priceText = itemDescription["price"] as? String
            self.imgUrl = (itemDescription["imageURL"] as? String)!
            self.bestOffer = itemDescription["bestOffer"] as? Bool
            self.desc = itemDescription["description"] as? String
            self.cat = itemDescription["category"] as? String
            self.condition = itemDescription["condition"] as? String
            self.conComment = itemDescription["conditionComment"] as? String
            self.sellerText = itemDescription["seller"] as? String
            addContent()
        }
    }
    // this function sets all of the different elements on the page such as text labels with the firebase data
    func addContent() {
        if imgUrl != ""  {
            downloadImage(url: (imgUrl)) // compressing image, still need to fix
            //itemImg.clipsToBounds = true
            //itemImg.contentMode = .scaleAspectFill
        } else {
            itemImg.image = UIImage(named: "Camera")
        }
        navTitle.title = titleText
        fullTitle.text = titleText
        price.text = "$\(priceText!)"
        if !bestOffer! {
            bestOfferLabel.isHidden = true
        } else {
            bestOfferLabel.isHidden = false
        }
        sellerName.setTitle(sellerText, for: .normal)
        sellerBtn.layer.cornerRadius = 7
        sellerBtn.contentEdgeInsets = UIEdgeInsetsMake(6, 10, 6, 10) // top, left, bottom, right
    }
    // downloading the image stored in firebase using the url added for each item
    public func downloadImage(url: String) {
        let imgUrl = URL(string: url)
        DispatchQueue.main.async {
            do {
                let data = try Data(contentsOf: imgUrl!)
                DispatchQueue.global().sync {
                    self.itemImg.image = UIImage(data: data)
                }
            } catch  {
                // handle error
            }
        }
    }
    
    @IBAction func messageSellerPressed(_ sender: Any) {
        if !MFMailComposeViewController.canSendMail() {
            // will always return false on simulator, have to do email testing on live device
            print("Mail services are not available")
            return
        } else {
            let mf = MFMailComposeViewController()
            mf.setToRecipients(["\(sellerText)@uw.edu"])
            mf.setSubject("Listing for \(titleText)")
            mf.mailComposeDelegate = self
            self.present(mf, animated: true, completion: nil)
        }
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "reuseIdentifier")
        }
        if id != "" {
            ref = Database.database().reference()
            ref?.child("items").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if indexPath.section == 0 { // condition section
                    cell?.textLabel?.text =  value!["condition"] as? String
                    if value!["conditionComment"] as? String != ""  { // if user gave a condition comment
                        cell?.detailTextLabel?.numberOfLines = 0;
                        cell?.detailTextLabel?.text = "Comment: \((value!["conditionComment"] as? String)!)"
                    }
                } else if indexPath.section == 1 { // description section
                    cell?.textLabel?.numberOfLines = 0;
                    cell?.textLabel?.text = value!["description"] as? String
                } else { // category section
                    cell?.textLabel?.text = value!["category"] as? String
                }
            }) { (error) in
                print(error.localizedDescription)
            }
       } else {
           if indexPath.section == 0 { // condition section
               cell?.textLabel?.text = condition
               if conComment != ""  {
                cell?.detailTextLabel?.numberOfLines = 0;
                cell?.detailTextLabel?.text = "Comment: \(conComment!)"
              }
           } else if indexPath.section == 1 { // description section
                cell?.textLabel?.numberOfLines = 0;
                cell?.textLabel?.text = desc
            } else { // category section
                cell?.textLabel?.text = cat
            }
        }
        return cell!
    }
    
    public func tableView(_ tableView: UITableView,
                          titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if (segue.identifier == "sellerProfileSegue") {
            let controller = segue.destination as! ProfileViewController
            controller.personInformation = self.sellerText!
            
            // self.items!.forEach { print($1) }
          
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
