//
//  UserDetailViewController.swift
//  GitClient
//
//  Created by John Leonard on 1/21/15.
//  Copyright (c) 2015 John Leonard. All rights reserved.
//

import UIKit

class UserDetailViewController: UIViewController {
  
  var selectedUser : User!

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
    override func viewDidLoad() {
      super.viewDidLoad()
      
      // set the displayed image and name for this user
      self.imageView.image = selectedUser.avatarImage
      self.nameLabel.text = selectedUser.name

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
