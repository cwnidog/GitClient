//
//  SearchRepositoriesViewController.swift
//  GitClient
//
//  Created by John Leonard on 1/19/15.
//  Copyright (c) 2015 John Leonard. All rights reserved.
//

import UIKit

class SearchRepositoriesViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate {

  @IBOutlet weak var tableViewOutlet: UITableView!
  
  @IBOutlet weak var searchBarOutlet: UISearchBar!
    
  var repositories = [Repository]() // the array of repositories satisfying the search criteria - may be empty
  let networkController = NetworkController()

  
    override func viewDidLoad() {
      super.viewDidLoad()
      
      // we're our own delegate for the tableView and searchBar
      self.tableViewOutlet.dataSource = self
      self.tableViewOutlet.delegate = self
      self.searchBarOutlet.delegate = self

      // Do any additional setup after loading the view.
    } // viewDidLoad()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  // MARK: UITableViewDataSource
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.repositories.count
  } // tableView(tableView(numberOfRowsInSection)
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("REPO_CELL", forIndexPath: indexPath) as UITableViewCell
    cell.textLabel?.text = self.repositories[indexPath.row].name // all we do for now is print the name of the repository
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    println("tableView delegate called.") // place holder
  }
  
  //MARK: UISearchBarDelegate
  
  // when we click on the search bar's search button get the repositories that satisfy the search term
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    println(searchBar.text)
    
    // call fetchRepositoriesForSearchTerm to send a request to the Git server for repositories
    self.networkController.fetchRepositoriesForSearchTerm(searchBar.text, callback: { (repositories, errorDescription) -> (Void) in
      if errorDescription == nil {
        self.repositories = repositories!
        self.tableViewOutlet.reloadData()
      } // no error
    })
    searchBar.resignFirstResponder()
  }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

} // SearchRepositoriesViewController
