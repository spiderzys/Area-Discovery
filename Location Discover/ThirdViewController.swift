//
//  ThirdViewController.swift
//  Location Discover
//
//  Created by YANGSHENG ZOU on 2016-06-20.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit
import Alamofire
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var tweets: [NSDictionary]?  // record the return tweets from api
    
    let tweetsTableViewReuseIdentifier = "tweet"  // tweets tableview reuse id
    
    
    
    func authenticate(_ completionBlock: @escaping (Void) -> ()) {
        // get authenticate from tweets
        let credentials = "\(consumerKey):\(consumerSecret)"
        let headers = ["Authorization": "Basic \(getBase64(credentials))"]
        let params: [String : AnyObject] = ["grant_type": "client_credentials" as AnyObject]
        
        Alamofire.request(URL.init(string:"https://api.twitter.com/oauth2/token")!, method: .post, parameters: params, headers: headers).responseJSON { response in
            if let JSON = response.result.value {
                self.accessToken = ((JSON as AnyObject).object(forKey: "access_token") as? String)!
                
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
        
        Alamofire.request(URL.init(string:baseUrlString + "search/tweets.json?q=&geocode="+String(appDelegate.addressCoordinate!.latitude)+","+String(appDelegate.addressCoordinate!.longitude)+","+String(radius)+"km&result_type=recent&count=50")!, method: .get, parameters: nil, headers: headers).responseJSON { response in
            
            
            if let result = response.result.value {
                
                print(result)
                
                self.tweets = (result as AnyObject).value(forKey: "statuses") as? [NSDictionary]
                if(self.tweets != nil){
                    // json parser
                    let user = UserDefaults.standard
                    user.set(self.accessToken, forKey: "token")
                    self.tweetsTableView.reloadData()
                    self.tweetsTableView.isScrollEnabled = true
                    
                }
                else {
                    let errors = (result as AnyObject).value(forKey: "errors") as! NSArray
                    let error = errors[0]
                    let code = (error as AnyObject).value(forKey: "code") as! NSNumber
                    if(code.int32Value == 89){
                        self.accessToken = nil
                        let user = UserDefaults.standard
                        user.set(self.accessToken, forKey: "token")
                        self.reloadTweets()
                    }
                }
            }
                
                
                
            else {
                self.showAlert("no network!")
            }
        }
        
    }
    
    
    func getBase64(_ data:String) -> String {
        
        // encoding data
        let credentialData = data.data(using: String.Encoding.utf8)!
        return credentialData.base64EncodedString(options: [])
    }
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tweetsTableView.register(UINib.init(nibName: "TweetsTableViewCell", bundle: nil), forCellReuseIdentifier: tweetsTableViewReuseIdentifier)
        tweetsTableView.rowHeight = UITableViewAutomaticDimension
        NotificationCenter.default.addObserver(self, selector: #selector(updateBackgroundImage), name: NSNotification.Name(rawValue: appDelegate.backgroundImageUpdatedNotificationName), object: nil) // add observer for background image uodate
        let user = UserDefaults.standard
        accessToken = user.object(forKey: "token") as? String // try to get access token from local storage
        // Do any additional setup after loading the view.
    }
    
    func updateBackgroundImage()  {
        // update background image when first viewcontroller finished
        DispatchQueue.main.async(execute: {
            self.backgroundImageView.image = self.appDelegate.backgroundImage
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // when the tweets need update
        super.viewWillAppear(animated)
        if(appDelegate.isThirdUpadateNeeded){
            self.backgroundImageView.image = self.appDelegate.backgroundImage
            reloadTweets()
        }
        
        
    }
    
    
    func reloadTweets(){
        
        self.imageCache?.removeAllObjects();
        
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
    
    
    
    @IBAction func segmentChanged(_ sender: AnyObject) {
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
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int{
        if (tweets == nil){
            // depends on whether tweets are available for specified area
            if accessToken != nil{
                noTweetsLabel.isHidden = false
            }
            return 0
        }
        else if(tweets?.count == 0){
            noTweetsLabel.isHidden = false
            return 0
            
        }
            
        else {
            noTweetsLabel.isHidden = true
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return tweets!.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return 100
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell{
        
        // custom the tweets tableview cell
        var tweetCell = tableView.dequeueReusableCell(withIdentifier: tweetsTableViewReuseIdentifier) as? TweetsTableViewCell
        if(tweetCell == nil){
            
            tweetCell = TweetsTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: tweetsTableViewReuseIdentifier)
        }
        tweetCell!.backgroundColor = UIColor.clear
        tweetCell!.userImageView.image = nil
        let tweet = tweets![(indexPath as NSIndexPath).row]
        
        let favourite  = tweet.value(forKey: "favorite_count") as! NSNumber
        tweetCell!.favouriteNumLabel.text = favourite.stringValue
        let text = tweet.value(forKey: "text") as! String
        tweetCell!.tweetLabel.text = text
        tweetCell!.tweetLabel.sizeToFit()
        
        let user = tweet.value(forKey: "user") as! NSDictionary
        tweetCell!.usernameLabel.text = user.value(forKey: "name") as? String
        
        
        
        let profileImageData = self.imageCache?.object(forKey: NSString.init(format: "%d,%d", indexPath.section,indexPath.row))
        if profileImageData != nil {
            tweetCell?.userImageView.image = UIImage.init(data: profileImageData as! Data)
        }
        else{
            
            let profileImageString = user.value(forKey: "profile_background_image_url") as? String
            
            
            
            if(profileImageString != nil){
                if (profileImageString?.characters.count > 6 ){
                    let profileImageUrl = URL.init(string: profileImageString!)!
                    // print(profileImageString!)
                    let task = URLSession.shared.dataTask(with: profileImageUrl, completionHandler: {(data, response, error) in
                        if (data != nil){
                            self.imageCache?.setObject(data! as NSData, forKey: NSString.init(format: "%d,%d", indexPath.section,indexPath.row))
                            DispatchQueue.main.async(execute: {
                                let updateCell = tableView.cellForRow(at: indexPath) as? TweetsTableViewCell
                                
                                if(updateCell != nil) {
                                    updateCell!.userImageView.image = UIImage.init(data: data!)
                                }
                            })
                        }
                    })
                    task.resume()
                }
            }
        }
        
        return tweetCell!
    }
    
    // -----------------------------end---------------------------------------------
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // reload when scroll to top
        if scrollView.contentOffset.y < -100 {
            print(scrollView.contentOffset.y)
            tweetsTableView.isScrollEnabled = false
            reloadTweets()
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
