//
//  ThirdViewController.swift
//  Location Discover
//
//  Created by YANGSHENG ZOU on 2016-06-20.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit
import Alamofire

class ThirdViewController: ViewController, UIScrollViewDelegate {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var radiusSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var noTweetsLabel: UILabel!
    @IBOutlet weak var tweetsTableView: UITableView!
    var radius = 1;
    
    var accessToken: String?
    let consumerKey = "tn7UBJpVn1W7Ke6XvzErIswIu"
    let consumerSecret = "d3f6erBXh20TEkJQFeJhfEwNDtUgs6ciLq0DVCrK6UoyV12c1a"
    let baseUrlString = "https://api.twitter.com/1.1/"

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var tweets: [NSDictionary]?
    
    let tweetsTableViewReuseIdentifier = "tweet"
    
        
    func authenticate(completionBlock: Void -> ()) {
        
        let credentials = "\(consumerKey):\(consumerSecret)"
        let headers = ["Authorization": "Basic \(getBase64(credentials))"]
        let params: [String : AnyObject] = ["grant_type": "client_credentials"]
        
        Alamofire.request(.POST, "https://api.twitter.com/oauth2/token", headers: headers, parameters: params)
            .responseJSON { response in
                if let JSON = response.result.value {
                    self.accessToken = (JSON.objectForKey("access_token") as? String)!
                   
                    completionBlock()
                }
                else {
                    self.showAlert("no network")
                }
        }
    }
    
    func loadTweets() {
        
        
           let headers = ["Authorization": "Bearer \(accessToken!)"]
           /* let params: [String : AnyObject] = [
               // "screen_name" : screenName,
             //   "count": self.pageSize
                "lat": (self.appDelegate.addressCoordinate?.latitude)!,
                "long":(self.appDelegate.addressCoordinate?.longitude)!
            ]*/
        
            Alamofire.request(.GET, self.baseUrlString + "search/tweets.json?q=&geocode="+String(appDelegate.addressCoordinate!.latitude)+","+String(appDelegate.addressCoordinate!.longitude)+","+String(radius)+"km&result_type=recent", headers: headers, parameters: nil)
                .responseJSON { response in
                
                    
                    if let result = response.result.value {
                        self.tweets = result.valueForKey("statuses") as? [NSDictionary]
                        if(self.tweets != nil){
                            
                           
                            self.tweetsTableView.reloadData()
                            self.tweetsTableView.scrollEnabled = true
                       //     print(t.valueForKey("favorite_count"))
                        }
                        
                        
                    }
                    else {
                        self.showAlert("no network")
                    }
            }
        
    }
    
    
    func getBase64(data:String) -> String {
            let credentialData = data.dataUsingEncoding(NSUTF8StringEncoding)!
            return credentialData.base64EncodedStringWithOptions([])
        }
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tweetsTableView.registerNib(UINib.init(nibName: "tweetsTableViewCell", bundle: nil), forCellReuseIdentifier: tweetsTableViewReuseIdentifier)
       // tweetsTableView.estimatedRowHeight = 50
        tweetsTableView.rowHeight = UITableViewAutomaticDimension
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateBackgroundImage), name: appDelegate.backgroundImageUpdatedNotificationName, object: nil)
        // Do any additional setup after loading the view.
    }
    
    func updateBackgroundImage()  {
        dispatch_async(dispatch_get_main_queue(), {
            self.backgroundImageView.image = self.appDelegate.backgroundImage
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if(appDelegate.isThirdUpadateNeeded){
            self.backgroundImageView.image = self.appDelegate.backgroundImage
            reloadTweets()
        }
  
        
    }
    
    
    func reloadTweets(){
        if(accessToken == nil){
            
            authenticate({
                self.loadTweets()
            })
            
        }
        else {
                loadTweets()
            
        }

    }
    
    
    
    @IBAction func segmentChanged(sender: AnyObject) {
        switch radiusSegmentedControl.selectedSegmentIndex {
        case 0:
            radius = 1
        case 1:
            radius = 10
        case 2:
            radius = 50
        default:
            radius = 100
        }
        reloadTweets()
    }
    
    //------------tweet tableview delegate---------------
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        if (tweets == nil){
            if accessToken != nil{
               noTweetsLabel.hidden = false
            }
            return 0
        }
        else if(tweets?.count == 0){
            noTweetsLabel.hidden = false
            return 0
            
        }
            
        else {
            noTweetsLabel.hidden = true
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return tweets!.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            
            return 100
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var tweetCell = tableView.dequeueReusableCellWithIdentifier(tweetsTableViewReuseIdentifier) as? tweetsTableViewCell
        if(tweetCell == nil){
            
             tweetCell = tweetsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: tweetsTableViewReuseIdentifier)
        }
        tweetCell!.backgroundColor = UIColor.clearColor()
        tweetCell!.userImageView.image = nil
        let tweet = tweets![indexPath.row]
        
        let favourite  = tweet.valueForKey("favorite_count") as! NSNumber
        tweetCell!.favouriteNumLabel.text = favourite.stringValue
        let text = tweet.valueForKey("text") as! String
        tweetCell!.tweetLabel.text = text
        tweetCell!.tweetLabel.sizeToFit()
        
        let user = tweet.valueForKey("user") as! NSDictionary
        tweetCell!.usernameLabel.text = user.valueForKey("name") as? String
        let profileImageString = user.valueForKey("profile_background_image_url") as? String
        
        if(profileImageString != nil){
            if (profileImageString?.characters.count > 6 ){
                let profileImageUrl = NSURL.init(string: profileImageString!)!
               // print(profileImageString!)
                let task = NSURLSession.sharedSession().dataTaskWithURL(profileImageUrl, completionHandler: {(data, response, error) in
                    if (data != nil){
                        dispatch_async(dispatch_get_main_queue(), {
                            let updateCell = tableView.cellForRowAtIndexPath(indexPath) as? tweetsTableViewCell
                            if(updateCell != nil) {
                            updateCell!.userImageView.image = UIImage.init(data: data!)
                            }
                        })
                    }
                })
                task.resume()
            }
        }
        
        
        return tweetCell!
    }
    
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y < -100 {
            print(scrollView.contentOffset.y)
            tweetsTableView.scrollEnabled = false
            reloadTweets()
        }
        
      //  print(scrollView.contentOffset.y)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        appDelegate.isThirdUpadateNeeded = false
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
