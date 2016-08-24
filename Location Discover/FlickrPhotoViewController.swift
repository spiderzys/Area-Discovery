//
//  FlickrPhotoViewController.swift
//  Location Discover
//
//  Created by YANGSHENG ZOU on 2016-06-25.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit

class FlickrPhotoViewController: UIViewController,NSXMLParserDelegate{
    
    @IBOutlet weak var flickrImageView: UIImageView!
    //var flickr: [String:String]
    @IBOutlet weak var noCommentsLabel: UILabel!  // the label shows when no comments found

    @IBOutlet weak var dateLabel: UILabel! // the label shows the date of image posted
    
    @IBOutlet weak var backgroundImageView: UIImageView! // the background imageview for this page
    
    @IBOutlet weak var commentLabel: UILabel!  // "comment"
    
    @IBOutlet weak var commentsTableView: UITableView! // tableview showing the comments
    @IBOutlet weak var titleLabel: UILabel!  // title label
    
    let baseUrlString =  "https://api.flickr.com/services/rest/?"  // base url of API
    let infoMethodString = "method=flickr.photos.getInfo"  //  photo infomation get method API
    let commentMethodString = "method=flickr.photos.comments.getList"  // photo comments get method API
    let apiKey = "api_key=38f54e0aad5942419017de0ae7944197"  // API KEY for flickr
    
    var photoTitle:String  // photo title string
    var photoId:String     // photo id string

  
    var comments: NSArray?
    let commentsTableViewReuseIdentifier = "comment"  // comments tableview reuseid string
   
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, id:String, title: String) {
        photoId = id
        photoTitle = title
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    
    @IBAction func dismiss(sender: AnyObject) {
      
        dismissViewControllerAnimated(true, completion: nil)
  
    }
    
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentsTableView.rowHeight = UITableViewAutomaticDimension
    // stub    photoId = "109722179"
        titleLabel.text = photoTitle
        
       
        
        
        
        let getInfoString = baseUrlString + infoMethodString + "&" + apiKey + "&" + "photo_id=" + photoId
        // the url string of request of photo infomation
        
        let infoData = NSData.init(contentsOfURL: NSURL.init(string: getInfoString)!)
         // get data of API
        if infoData != nil {
            // parse XML data
            let infoParser = NSXMLParser.init(data: infoData!)
            infoParser.delegate = self
            infoParser.parse()
            
        }
        
        let getCommentString = baseUrlString + commentMethodString + "&" + apiKey + "&" + "photo_id=" + photoId + "&format=json&nojsoncallback=1"
        // the url string of request of photo comments

        let commentData = NSData.init(contentsOfURL: NSURL.init(string: getCommentString)!)
        
        if commentData != nil {
            
            do{
                // JSON parse
                let dict:NSDictionary = try NSJSONSerialization.JSONObjectWithData(commentData!, options: []) as! NSDictionary
                
                let stat = dict.valueForKey("stat") as! String
                if(stat == "ok"){
                    let comment = dict.valueForKey("comments") as? NSDictionary
                    comments = comment?.valueForKey("comment") as? NSArray
                    if comments != nil {
                
                        commentLabel.text = String(comments!.count)
                        
                    }
                    
                    else {
                        
                        commentLabel.text = "0"
                    }
                   
                    commentsTableView.reloadData()
                    
                }
                
            }catch _ {
                
            }
            
        }
        
       
        
  
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        // delegate method of XML parser, when paser start to parse element
        
        if elementName == "dates"{
            
            dateLabel.text = attributeDict["taken"]
        }
            
            
       

    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //-----------------tableview delegate-----------------------
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        // depends on whether there are comments for the photo
        if (comments == nil){
            noCommentsLabel.hidden = false
            return 0
        }
            
        else {
            noCommentsLabel.hidden = true
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        // depends on the number of comments
        return comments!.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 40
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        // custom comment cell
        var commentCell = tableView.dequeueReusableCellWithIdentifier(commentsTableViewReuseIdentifier)
        if(commentCell == nil){
            
            commentCell = TweetsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: commentsTableViewReuseIdentifier)
            commentCell?.textLabel?.numberOfLines = 0
            commentCell?.textLabel?.font = UIFont.systemFontOfSize(13)
            commentCell!.backgroundColor = UIColor.clearColor()
           // commentCell?.textLabel?.textColor = noCommentsLabel.textColor
        }
        
        
        
        let comment = comments![indexPath.row]
 
        commentCell!.textLabel?.text = comment.valueForKey("_content") as? String
        commentCell?.textLabel?.sizeToFit()
     
        
        return commentCell!
    }
    
   // - -----------------------------------end---------------------------------------
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
