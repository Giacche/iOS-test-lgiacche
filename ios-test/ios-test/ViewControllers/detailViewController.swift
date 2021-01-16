//
//  detailViewController.swift
//  ios-test
//
//  Created by Lucas Nahuel Giacche on 15/01/2021.
//

import UIKit

class detailViewController: UIViewController {

    var authorPost: String!
    var titlePost: String!
    var thumbnailURLPost: String!
    
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var titleView: UITextView!
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        author.text = authorPost
        titleView.text = titlePost
        
        if let entryURLString = thumbnailURLPost, entryURLString != "default", let entryURL = URL(string: entryURLString) {
            //Get image
            RedditService.getData(from: entryURL) { (data, response, error) in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async() {
                    let image = UIImage(data: data)
                    self.image.image = image
                }
            }
        }
    }

}
