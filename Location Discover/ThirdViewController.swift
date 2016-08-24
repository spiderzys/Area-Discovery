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

    @IBOutlet weak var backgroundImageView: UIImageView!   // background imageview
    @IBOutlet weak var radiusSegmentedControl: UISegmentedControl!   // for choosing the radius of tweets
    
    @IBOutlet weak var noTweetsLabel: UILabel!    // show when no tweets in specified area
    @IBOutlet weak var tweetsTableView: UITableView!    // tableview shows the tweets
    var radius = 1;
    
    var accessToken: String?   // the access token for api request
    let consumerKey = "tn7UBJpVn1W7Ke6XvzErIswIu"    // my key and secret
    let consumerSecret = "d3f6erBXh20TEkJQFeJhfEwNDtUgs6ciLq0DVCrK6UoyV12c1a"
    let baseUrlString = "https://api.twitter.com/1.1/"   // tweets api base url

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var tweets: [NSDictionary]?  // record the return tweets from api
    
    let tweetsTableViewReuseIdentifier = "tweet"  // tweets tableview reuse id
    
    
        
    func authenticate(completionBlock: Void -> ()) {
        // get authenticate from tweets
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
          // get tweets after authorization
        
           let headers = ["Authorization": "Bearer \(accessToken!)"]
        
            Alamofire.request(.GET, self.baseUrlString + "search/tweets.json?q=&geocode="+String(appDelegate.addressCoordinate!.latitude)+","+String(appDelegate.addressCoordinate!.longitude)+","+String(radius)+"km&result_type=recent&count=50", headers: headers, parameters: nil)
                .responseJSON { response in
           
                    
                    if let result = response.result.value {
                        
                        print(result)
                        
                        self.tweets = result.valueForKey("statuses") as? [NSDictionary]
                        if(self.tweets != nil){
                            // json parser
                            let user = NSUserDefaults.standardUserDefaults()
                            user.setObject(self.accessToken, forKey: "token")
                            self.tweetsTableView.reloadData()
                            self.tweetsTableView.scrollEnabled = true
                      
                        }
                        else {
                            let errors = result.valueForKey("errors") as! NSArray
                            let error = errors[0]
                            let code = error.valueForKey("code") as! NSNumber
                            if(code.intValue == 89){
                               self.accessToken = nil
                                let user = NSUserDefaults.standardUserDefaults()
                                user.setObject(self.accessToken, forKey: "token")
                               self.reloadTweets()
                            }
                        }
                    }
                        
                        
                    
                    else {
                        self.showAlert("no network!")
                    }
            }
        
    }
    
    
    func getBase64(data:String) -> String {
        
           // encoding data
            let credentialData = data.dataUsingEncoding(NSUTF8StringEncoding)!
            return credentialData.base64EncodedStringWithOptions([])
        }
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tweetsTableView.registerNib(UINib.init(nibName: "TweetsTableViewCell", bundle: nil), forCellReuseIdentifier: tweetsTableViewReuseIdentifier)
              tweetsTableView.rowHeight = UITableViewAutomaticDimension
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateBackgroundImage), name: appDelegate.backgroundImageUpdatedNotificationName, object: nil) // add observer for background image uodate
        let user = NSUserDefaults.standardUserDefaults()
        accessToken = user.objectForKey("token") as? String // try to get access token from local storage
        // Do any additional setup after loading the view.
    }
    
    func updateBackgroundImage()  {
        // update background image when first viewcontroller finished
        dispatch_async(dispatch_get_main_queue(), {
            self.backgroundImageView.image = self.appDelegate.backgroundImage
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        // when the tweets need update
        super.viewWillAppear(animated)
        if(appDelegate.isThirdUpadateNeeded){
            self.backgroundImageView.image = self.appDelegate.backgroundImage
            reloadTweets()
        }
  
        
    }
    
    
    func reloadTweets(){
        if(accessToken == nil){
            // if accessToken not available, start from authentication
            authenticate({
                self.loadTweets()
            })
            
        }
        else {
            // otherwise, start from load
                loadTweets()
            
        }

    }
    
    
    
    @IBAction func segmentChanged(sender: AnyObject) {
        // change the radius parameter and reload tweets
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
            // depends on whether tweets are available for specified area
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
        
        // custom the tweets tableview cell
        var tweetCell = tableView.dequeueReusableCellWithIdentifier(tweetsTableViewReuseIdentifier) as? TweetsTableViewCell
        if(tweetCell == nil){
            
             tweetCell = TweetsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: tweetsTableViewReuseIdentifier)
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
                            let updateCell = tableView.cellForRowAtIndexPath(indexPath) as? TweetsTableViewCell
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
    
    // -----------------------------end---------------------------------------------
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // reload when scroll to top
        if scrollView.contentOffset.y < -100 {
            print(scrollView.contentOffset.y)
            tweetsTableView.scrollEnabled = false
            reloadTweets()
        }
        
     
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
