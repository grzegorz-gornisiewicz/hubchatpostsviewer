//
//  HubchatPostsTVC.swift
//  HubchatPostLister
//
//  Created by Grzegorz Górnisiewicz on 19.12.2016.
//  Copyright © 2016 Long Road. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import AlamofireImage

enum TargetImage:Int {
    case headerImage = 0
    case logoImage
}

class HubchatPostsTVC: UITableViewController {
    var posts:[Any] = []
    var forumTitle:String = ""
    var forumDescription:String = ""
    var forumLogoUrl:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.backgroundColor = UIColor.white

        downloadForum()
        downloadPosts()
    }

    func downloadForum() {
        DispatchQueue.main.async {
            Alamofire.request("https://api.hubchat.com/v1/forum/photography").responseJSON { response in
                if let JSON = response.result.value as? NSDictionary {
                    if let forum = JSON.value(forKey: "forum") as? NSDictionary {

                        self.forumTitle = forum.value(forKey: "title") as! String
                        self.forumDescription = forum.value(forKey: "description") as! String
                        self.forumLogoUrl = (forum.value(forKey: "image") as! NSDictionary).value(forKey: "url") as! String
                        
                        print("self.forumLogoUrl:\(self.forumLogoUrl)")

                        if let url = (forum.value(forKey: "headerImage") as! NSDictionary).value(forKey: "url") as? String {
                            let statusBarSize = UIApplication.shared.statusBarFrame.size
                            let targetHeight:CGFloat = Swift.min(statusBarSize.width, statusBarSize.height) + self.navigationController!.navigationBar.frame.size.height
                            let frame:CGRect = CGRect(x: 0, y: 0, width: self.navigationController!.navigationBar.frame.size.width, height: targetHeight)
                            let imageContainer:UIView = UIView(frame: frame)
                            let imageView:UIImageView = UIImageView(frame: frame)

                            imageView.contentMode = UIViewContentMode.scaleAspectFill
                            imageView.af_setImage(withURL: URL(string: url)!, placeholderImage:nil, imageTransition: UIImageView.ImageTransition.crossDissolve(1.0))
                            imageContainer.clipsToBounds = true
                            imageContainer.addSubview(imageView)

                            self.navigationController?.view.addSubview(imageContainer)
                        }
                    }
                }
            }
        }
    }

    func downloadPosts() {
        DispatchQueue.main.async {
            Alamofire.request("https://api.hubchat.com/v1/forum/photography/post").responseJSON { response in
                if let JSON = response.result.value as? NSDictionary {
                    self.posts = JSON.value(forKey: "posts") as! [Any]
                    self.tableView.reloadData()
                }
            }
        }
    }

    func reloadData() {
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if posts.count == 0 {
            return 1
        }
        
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.forumLogoUrl != "" {
            return 80.0
        }
        
        return 0.0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame:CGRect = CGRect(x: 0, y: 0, width: self.navigationController!.navigationBar.frame.size.width, height: 40.0)
        let headerView:UIView = UIView(frame: frame)

        let logoContainer:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 80.0, height: 80.0))
        logoContainer.clipsToBounds = true

        let logoImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 64.0, height: 64.0))
        logoImageView.contentMode = UIViewContentMode.scaleAspectFit
        logoImageView.af_setImage(withURL: URL(string: self.forumLogoUrl)!, placeholderImage:nil, imageTransition: UIImageView.ImageTransition.crossDissolve(1.0))

        headerView.clipsToBounds = true
        headerView.backgroundColor = UIColor.white

        logoContainer.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(logoContainer)
            make.size.equalTo(64.0)
            make.edges.equalTo(logoContainer).inset(UIEdgeInsetsMake(4, 4, 40, 4))
        }

        headerView.addSubview(logoContainer)
        
        let titleLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: headerView.frame.size.width, height: 16.0))
        titleLabel.text = forumTitle
        titleLabel.font = UIFont.systemFont(ofSize: 12.0)
        titleLabel.sizeToFit()

        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(logoContainer.frame.size.width + 4)
            make.centerY.equalTo(logoImageView)
        }
        
        let descriptionLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: headerView.frame.size.width, height: 32.0))
        descriptionLabel.text = forumDescription
        descriptionLabel.numberOfLines = 2
        descriptionLabel.text = forumDescription
        descriptionLabel.font = UIFont.systemFont(ofSize: 10.0)
        descriptionLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        descriptionLabel.sizeToFit()

        headerView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(headerView).offset(12)
            make.right.bottom.equalTo(headerView).offset(-8)
        }

        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if posts.count == 0 {
            return 44.0
        }

        return 88.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HubchatPost", for: indexPath)

        if posts.count == 0 {
            let indicator:UIActivityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            
            cell.contentView.addSubview(indicator)

            indicator.isHidden = false
            indicator.startAnimating()
            indicator.hidesWhenStopped = true
            indicator.snp.makeConstraints { (make) -> Void in
                make.center.equalTo(cell.contentView)
            }
        } else {
            for view in cell.contentView.subviews {
                if view is UIActivityIndicatorView {
                    (view as! UIActivityIndicatorView).stopAnimating()
                }
                view.removeFromSuperview()
            }
/*
             Post text
             User (avatar, username)
             Images (from entities)
             Upvotes
 */
        }

        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
