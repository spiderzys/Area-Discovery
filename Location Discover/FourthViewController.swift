//
//  FourthViewController.swift
//  Location Discover
//
//  Created by YANGSHENG ZOU on 2016-06-21.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit

class FourthViewController: UIViewController, NSXMLParserDelegate {
    
    @IBOutlet weak var radiusSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var flickrCollectionView: UICollectionView!
    
    let flickrCollectionViewReuseIdentifier = "flickr"
    var radius = 1
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let baseUrlString = "https://api.flickr.com/services/rest/?"
    let apiKey = "api_key=38f54e0aad5942419017de0ae7944197"
    let searchMethodString = "method=flickr.photos.search"
    let favoriteMethod =  "method=flickr.photos.getFavorites"
    let formatString = "format=rest"
    
    var flickrArray = [[String:String]]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flickrCollectionView.registerNib(UINib.init(nibName: "FlickrCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: flickrCollectionViewReuseIdentifier)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if appDelegate.isFourthUpdateNeeded {
            reloadFlickrs()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func reloadFlickrs() {
        let currentLocationCoordinateString = "lat="+String(appDelegate.addressCoordinate!.latitude)+"&lon="+String(appDelegate.addressCoordinate!.longitude)
        
        let format = NSDateFormatter.init()
        format.dateFormat = "yyyy-MM-dd"
        let components = NSDateComponents()
        components.month = -1
        
        let dateString = "min_taken_date=" + format.stringFromDate(NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: NSDate(), options: [])!)
        
        //  let dateString = "min_taken_date=" + String(year!) + "-01-01"
        //  let currentYearString
        let searchRequestString = baseUrlString + searchMethodString + "&" + currentLocationCoordinateString + "&" + formatString + "&" + dateString + "&" + apiKey + "&order=date-taken-desc&privacy_filter=1"
        print(searchRequestString)
        
        let searchData = NSData.init(contentsOfURL: NSURL.init(string: searchRequestString)!)
        
        
        
        if searchData != nil {
            
            
            let parser = NSXMLParser.init(data: searchData!)
            parser.delegate = self
            parser.parse()
            
        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
           flickrCollectionView.reloadData()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "photo"{
            
            flickrArray.append(attributeDict)
        }
    }
    
    func collectionView(collectionView: UICollectionView,
                        didSelectItemAtIndexPath indexPath: NSIndexPath){
        
    }
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout,sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize{
        
        return CGSizeMake(self.view.frame.width*0.3, self.view.frame.width*0.3)
    }
    
    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int{
        
        // todo : show no pics available
        return flickrArray.count
        
    }
    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let flickrCell = collectionView.dequeueReusableCellWithReuseIdentifier(flickrCollectionViewReuseIdentifier, forIndexPath: indexPath) as! FlickrCollectionViewCell
        flickrCell.backgroundImageView.image = nil
        let flickr = flickrArray[indexPath.row]
        
        
        let farm = flickr["farm"]!
        let server = flickr["server"]!
        let secret = flickr["secret"]!
        let id = flickr["id"]!
        
        let favortieString = baseUrlString + favoriteMethod + "&photo_id=" + id + "&" + apiKey + "&format=json&nojsoncallback=1"        
        
        let backgroundImageString = "https://farm" + farm + ".staticflickr.com/" + server + "/" + id + "_" + secret + ".jpg"
        let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL.init(string: backgroundImageString)!, completionHandler: {(data, response, error) in
            
            let updateCell = collectionView.cellForItemAtIndexPath(indexPath) as? FlickrCollectionViewCell
            if updateCell != nil && data != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    updateCell?.backgroundImageView.image = UIImage.init(data: data!)
                })
            }
            
        })
        
        task.resume()
        
        let task2 = NSURLSession.sharedSession().dataTaskWithURL(NSURL.init(string: favortieString)!, completionHandler: {(data, response, error) in
            if (data != nil) {
                do{
                    let favortie = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                    
                    let dic = favortie.valueForKey("photo") as! NSDictionary
                    let favoriteNum = dic.valueForKey("total") as! String
                    let updateCell = collectionView.cellForItemAtIndexPath(indexPath) as? FlickrCollectionViewCell
                    
                    if updateCell != nil && data != nil {
                        dispatch_async(dispatch_get_main_queue(), {
                            updateCell?.favouriteNumLabel.text = favoriteNum
                        })
                    }
                    
                }
                catch _ {
                    
                }
            }
            
        })
        task2.resume()
        
        return flickrCell
    }
    
    @IBAction func segmentChanged(sender: AnyObject) {
        switch radiusSegmentedControl.selectedSegmentIndex {
        case 0:
            radius = 1
        case 1:
            radius = 5
        case 2:
            radius = 10
        default:
            radius = 30
        }
        reloadFlickrs()
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
