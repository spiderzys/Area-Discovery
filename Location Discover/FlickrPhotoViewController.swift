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
    @IBOutlet weak var noCommentsLabel: UILabel!

    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    let baseUrlString =  "https://api.flickr.com/services/rest/?"
    let infoMethodString = "method=flickr.photos.getInfo"
    let commentMethodString = "method=flickr.photos.comments.getList"
    let apiKey = // the same as FourthViewController
    var photoTitle:String
    var photoId:String
  //  var flickrInfoArray = [[String:String]]()
  //  var flickrCommentArray = [[String:String]]()
    var comments: NSArray?
    let commentsTableViewReuseIdentifier = "comment"
   
    
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
        
        let infoData = NSData.init(contentsOfURL: NSURL.init(string: getInfoString)!)
    
        if infoData != nil {
            
            let infoParser = NSXMLParser.init(data: infoData!)
            infoParser.delegate = self
            infoParser.parse()
            
        }
        
        let getCommentString = baseUrlString + commentMethodString + "&" + apiKey + "&" + "photo_id=" + photoId + "&format=json&nojsoncallback=1"

        let commentData = NSData.init(contentsOfURL: NSURL.init(string: getCommentString)!)
        
        if commentData != nil {
            
            do{
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
        
       
        
        
       

      //  dateLabel.text = flickr[]
        // Do any additional setup after loading the view.
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        /*
        if elementName == "owner"{
            
            flickrInfoArray.append(attributeDict)
        }
        */
        if elementName == "dates"{
            
            dateLabel.text = attributeDict["taken"]
        }
            
            
       

    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        
          //  let owner = flickrInfoArray[0]
         //   usernameLabel.text = owner["username"]!
          //  let dates = flickrInfoArray[0]
          //  dateLabel.text = dates["taken"]!
        
            
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //-----------------tableview delegate-----------------------
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
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
        return comments!.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 40
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
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
    
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
