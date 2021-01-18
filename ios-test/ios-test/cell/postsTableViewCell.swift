//
//  postsTableViewswift
//  ios-test
//
//  Created by Lucas Nahuel Giacche on 15/01/2021.
//

import UIKit

protocol cellDelegate: AnyObject {
    func btnCloseTapped(cell: postsTableViewCell)
}

class postsTableViewCell: UITableViewCell {
    
    var entry: EntryData!
    
    @IBOutlet weak var seenIndicator: UIImageView!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var timeFromPost: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var titleOfPost: UITextView!
    @IBOutlet weak var dismissPost: UIButton!
    @IBOutlet weak var countComments: UILabel!
    @IBOutlet weak var authorLeftConstraint: NSLayoutConstraint!
    
    
    weak var delegate: cellDelegate?
    
    @IBAction func dismissPostAction(_ sender: Any) {
        delegate?.btnCloseTapped(cell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleOfPost.textContainer.maximumNumberOfLines = 4
        titleOfPost.textContainer.lineBreakMode = .byTruncatingTail
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        seenIndicator.isHidden = false
        authorLeftConstraint.constant = 12
        author.textColor = .white
        titleOfPost.textColor = .white
        timeFromPost.textColor = .white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadData(entry: EntryData){
        author.text = entry.authorName
        titleOfPost.text = entry.title
        countComments.text = "\(entry.commentsAmount) comments"
        
        getImage(entryImage: entry)
        getTime(entryTime: entry)
        
        titleOfPost.centerVertically()

        if(entry.urlBigImage != nil){
            let imageBigUrl = MyTapGesture(target: self, action: #selector(self.openImage))
            imageBigUrl.imageUrlToOpen = entry.urlBigImage
            thumbnail.isUserInteractionEnabled = true
            thumbnail.addGestureRecognizer(imageBigUrl)
        }else{
            thumbnail.isUserInteractionEnabled = false
        }
        
        if(entry.seenDot){
            seenIndicator.isHidden = true
            authorLeftConstraint.constant = -12
            author.textColor = .lightGray
            titleOfPost.textColor = .lightGray
            timeFromPost.textColor = .lightGray
        }
            
    }
    
    @objc func openImage(sender : MyTapGesture) {
        let url = sender.imageUrlToOpen
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }
    
    func getImage(entryImage: EntryData){
        //Thumbnail image view
        if let entryURLString = entryImage.thumbnailURL, entryURLString != "default", let entryURL = URL(string: entryURLString) {
            //Get image
            RedditService.getData(from: entryURL) { (data, response, error) in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async() {
                    let image = UIImage(data: data)
                    self.thumbnail.image = image
                    self.layoutIfNeeded()
                }
            }
        }
    }
    
    func getTime(entryTime: EntryData){
        
        let now = Date()
        let differenceOfTime = now.timeIntervalSince1970 - entryTime.timeCreated
        
        if differenceOfTime < (60 * 60) {
            let minutes = floor(differenceOfTime / 60)
            timeFromPost.text = "\(minutes.roundDouble) minutes ago"
        }else{
            if differenceOfTime < (60 * 60 * 24) {
                let hours = floor(differenceOfTime / 60 / 60)
                timeFromPost.text = "\(hours.roundDouble) hours ago"
            }else{
                if differenceOfTime < (60 * 60 * 24 * 7) {
                    let days = floor(differenceOfTime / 60 / 60 / 24)
                    timeFromPost.text = "\(days.roundDouble) days ago"
                }
            }
        }
        
    }

}

class MyTapGesture: UITapGestureRecognizer {
    var imageUrlToOpen = String()
}


extension TimeInterval{
    var roundDouble: String{
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

extension UITextView {

    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }

}
