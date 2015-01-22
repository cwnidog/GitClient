//
//  SearchUsersViewController.swift
//  GitClient
//
//  Created by John Leonard on 1/21/15.
//  Copyright (c) 2015 John Leonard. All rights reserved.
//

import UIKit

class SearchUsersViewController: UIViewController, UICollectionViewDataSource, UISearchBarDelegate, UINavigationControllerDelegate {
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  @IBOutlet weak var searchBar: UISearchBar!
  
  var users = [User]()// an array of Github users

    override func viewDidLoad() {
        super.viewDidLoad()
      self.collectionView.dataSource = self
      self.searchBar.delegate = self
      self.navigationController?.delegate = self

        // Do any additional setup after loading the view.
    } // viewDidLoad()
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.delegate = nil // fix the zombie UINavigationController problem
  } // viewWillAppear()
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.users.count
  } // collectionView(numberOfItemsInSection)
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("USER_CELL", forIndexPath: indexPath) as UserCell
    cell.imageView.image = nil // empty the image, so don't show old one
    
    // get the user we're interested in
    var user = self.users[indexPath.row]
    if user.avatarImage == nil {
      // need to ask for an image
      NetworkController.sharedNetworkController.fetchAvatarImageForURL(user.avatarURL, completionHandler: { (image) -> (Void) in
        cell.imageView.image = image
        user.avatarImage = image
        self.users[indexPath.row] = user
      }) // completionHandler
    } // if avatar image is nil
    else {
      // have a stored image, use it
      cell.imageView.image = user.avatarImage
    } // else
    
    return cell
    
  } // collectionView(cellForItemAtIndexPath)

// MARK: UISearchBarDelegate
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    
    NetworkController.sharedNetworkController.fetchUsersForSearchTerm(searchBar.text, callback: { (users, errorDescription) -> (Void) in
      if errorDescription == nil {
        self.users = users!
        self.collectionView.reloadData()
      }
    }) // callback enclosure
  } // searchBarSearchButtonClicked
  
  func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    if toVC is UserDetailViewController {
      // return the animation controller
      return ToUserDetailAnimationController()
    } // moving from the SearchUsers VC
    return nil
  } // navigationController
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "SHOW_USER_DETAIL" {
      let destinationVC = segue.destinationViewController as UserDetailViewController
      let selectedIndexPath = self.collectionView.indexPathsForSelectedItems().first as NSIndexPath
      
      destinationVC.selectedUser = self.users[selectedIndexPath.row]
    } // if segue.identifier
  } // prepareForSegue()

} // SearchUsersViewController
