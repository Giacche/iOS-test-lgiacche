//
//  ViewController.swift
//  ios-test
//
//  Created by Lucas Nahuel Giacche on 14/01/2021.
//

import UIKit
import Foundation


class mainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, cellDelegate {
    
    @IBOutlet weak var viewControllerTitle: UILabel!
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var dismissAllPostsBtn: UIButton!
    
    @IBAction func dismissAllPostsAction(_ sender: Any) {
        entries.removeAll()
        
        UIView.transition(with: self.view,
                          duration: 0.15,
                          options: [.curveEaseInOut, .transitionCrossDissolve],
                          animations: {
                              self.postsTableView.reloadData()
        }, completion: nil)
        
    }
        
    let refreshControl = UIRefreshControl()
    
    var entries: [EntryData] = []
    
    var indexToSegue : Int!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Refresh control
        
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(getPosts), for: .valueChanged)
        postsTableView.addSubview(refreshControl)
               
        //Get posts
        getPosts()
    }
    
    
    @objc func getPosts() {
        RedditService.requestData(success: { (entries) in
            self.entries = entries
            self.postsTableView.reloadData()
            self.refreshControl.endRefreshing()
        }) { (error) in
            self.refreshControl.endRefreshing()
            print("Error")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func btnCloseTapped(cell: postsTableViewCell) {
        let indexPath = self.postsTableView.indexPath(for: cell)
        print(indexPath!.row)
        entries.remove(at: indexPath!.row)
        postsTableView.deleteRows(at: [indexPath!], with: .fade)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if(segue.identifier == "showDetailPost"){
            let detailSegue = segue.destination as! detailViewController
            detailSegue.authorPost = entries[indexToSegue].authorName
            detailSegue.titlePost = entries[indexToSegue].title
            detailSegue.thumbnailURLPost = entries[indexToSegue].thumbnailURL
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellPost", for: indexPath) as? postsTableViewCell else {
            return UITableViewCell()
        }
        cell.loadData(entry: entries[indexPath.row])
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            entries.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        indexToSegue = indexPath.row
        performSegue(withIdentifier: "showDetailPost", sender: self)
    }
    
}

