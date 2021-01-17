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
    @IBOutlet weak var loader: UILabel!
    @IBOutlet weak var reloadPosts: UIButton!
    
    //iPad Outlets
    
    @IBOutlet weak var tableViewContainer: UIView!
    @IBOutlet weak var detailContainerView: UIView!
    @IBOutlet weak var authorDetail: UILabel!
    @IBOutlet weak var imageDetail: UIImageView!
    @IBOutlet weak var titleDetail: UITextView!
    @IBOutlet weak var widthOfTableView: NSLayoutConstraint!
    @IBOutlet weak var widthOfDetailView: NSLayoutConstraint!
    
    
    @IBAction func downLoadImageAction(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(self.imageDetail.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func reloadPostsAction(_ sender: Any) {
        self.reloadPosts.isHidden = true
        self.loader.isHidden = false
        getPosts()
    }
    
    @IBAction func dismissAllPostsAction(_ sender: Any) {
        entries.removeAll()
        
        UIView.transition(with: self.view, duration: 0.15, options: [.curveEaseInOut, .transitionCrossDissolve], animations: {
            self.postsTableView.reloadData()
            self.postsTableView.isHidden = true
            self.reloadPosts.isHidden = false
        }, completion: nil)
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            detailContainerView.isHidden = true
        }
    }
        
    let refreshControl = UIRefreshControl()
    
    var entries: [EntryData] = []
    
    var indexToSegue : Int!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadPosts.isHidden = true
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(getPosts), for: .valueChanged)
        postsTableView.addSubview(refreshControl)
        postsTableView.isHidden = true
        if(UIDevice.current.userInterfaceIdiom == .pad){
            detailContainerView.isHidden = true
            
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
            swipeRight.direction = .right
            self.detailContainerView.addGestureRecognizer(swipeRight)

            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
            swipeLeft.direction = .left
            self.detailContainerView.addGestureRecognizer(swipeLeft)
        }
        
        //Get posts
        getPosts()
        
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {
            case .right:
                print("Swiped right")
                showTableView()
            case .left:
                print("Swiped left")
                hideTableView()
            default:
                break
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            if(UIDevice.current.userInterfaceIdiom == .pad){
                if UIDevice.current.orientation.isLandscape {
                    self.tableViewContainer.frame = CGRect(x: 0, y: self.tableViewContainer.frame.origin.y, width: self.tableViewContainer.frame.size.width, height: self.tableViewContainer.frame.size.height)
                } else {
                    if !(self.detailContainerView.isHidden){
                        self.hideTableView()
                    }
                }
            }
        }
    }
    
    
    func hideTableView(){
        UIView.animate(withDuration: 0.5,delay: 0, usingSpringWithDamping: 1.0,initialSpringVelocity: 1.0,options: .curveEaseInOut, animations: {
            self.tableViewContainer.frame = CGRect(x: -self.tableViewContainer.frame.size.width, y: self.tableViewContainer.frame.origin.y, width: self.tableViewContainer.frame.size.width, height: self.tableViewContainer.frame.size.height)
            
            
            self.detailContainerView.frame = CGRect(x: 0, y: self.detailContainerView.frame.origin.y, width: self.view.frame.size.width - self.tableViewContainer.frame.size.width, height: self.detailContainerView.frame.size.height)
          }, completion: nil)
    }
    
    func showTableView(){
        UIView.animate(withDuration: 0.5,delay: 0, usingSpringWithDamping: 1.0,initialSpringVelocity: 1.0,options: .curveEaseInOut, animations: {
            self.tableViewContainer.frame = CGRect(x: 0, y: self.tableViewContainer.frame.origin.y, width: self.tableViewContainer.frame.size.width, height: self.tableViewContainer.frame.size.height)
            
            self.detailContainerView.frame = CGRect(x: 0, y: self.detailContainerView.frame.origin.y, width: self.view.frame.size.width, height: self.detailContainerView.frame.size.height)
          }, completion: nil)
    }
    
    @objc func getPosts() {
        RedditService.requestData(success: { (entries) in
            self.entries = entries
            self.postsTableView.reloadData()
            self.postsTableView.isHidden = false
            self.loader.isHidden = true
            self.refreshControl.endRefreshing()
            self.reloadPosts.isHidden = true
        }) { (error) in
            self.refreshControl.endRefreshing()
            print("Error")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {

        if let error = error {

            let alert = UIAlertController(title: "Attention", message: "The image could not be saved to your gallery", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "oK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

        } else {

            let alert = UIAlertController(title: "Attention", message: "The image was saved in your gallery successfully", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "oK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
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
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            authorDetail.text = entries[indexPath.row].authorName
            titleDetail.text = entries[indexPath.row].title
            if let entryURLString = entries[indexPath.row].thumbnailURL, entryURLString != "default", let entryURL = URL(string: entryURLString) {
                //Get image
                RedditService.getData(from: entryURL) { (data, response, error) in
                    guard let data = data, error == nil else { return }
                    DispatchQueue.main.async() {
                        let image = UIImage(data: data)
                        self.imageDetail.image = image
                    }
                }
            }
            detailContainerView.isHidden = false
        }else{
            performSegue(withIdentifier: "showDetailPost", sender: self)
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? postsTableViewCell {
            entries[indexPath.row].seenDot = true
            cell.seenIndicator.isHidden = true
            cell.authorLeftConstraint.constant = -12
            cell.author.textColor = .lightGray
            cell.titleOfPost.textColor = .lightGray
            cell.timeFromPost.textColor = .lightGray
            cell.dismissPost.setTitleColor(.lightGray, for: .normal)
        }
    }
}

