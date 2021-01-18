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
    @IBOutlet weak var downloadImage: UIButton!
    
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func downloadImageAction(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(self.image.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
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
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {

        if let error = error {

            let alert = UIAlertController(title: "Attention", message: "The image could not be saved to your gallery", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

        } else {

            let alert = UIAlertController(title: "Attention", message: "The image was saved in your gallery successfully", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}
