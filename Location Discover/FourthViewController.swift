//
//  FourthViewController.swift
//  Location Discover
//
//  Created by YANGSHENG ZOU on 2016-06-21.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit

class FourthViewController: ViewController, XMLParserDelegate {
    
    @IBOutlet weak var radiusSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var flickrCollectionView: UICollectionView!
    
    @IBOutlet weak var noPhotosLabel: UILabel!
    
    let flickrCollectionViewReuseIdentifier = "flickr"
    @IBOutlet weak var backgroundImageView: UIImageView!
    var radius = 1
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let baseUrlString = "https://api.flickr.com/services/rest/?"
    let apiKey = "api_key=38f54e0aad5942419017de0ae7944197"
    let searchMethodString = "method=flickr.photos.search"
    let favoriteMethod =  "method=flickr.photos.getFavorites"
    let formatString = "format=rest"
    
    var flickrArray = [[String:String]]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBackgroundImage), name: NSNotification.Name(rawValue: appDelegate.backgroundImageUpdatedNotificationName), object: nil)
        flickrCollectionView.register(UINib.init(nibName: "FlickrCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: flickrCollectionViewReuseIdentifier)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        if appDelegate.isFourthUpdateNeeded {
            reloadFlickrs()
        }
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        appDelegate.isFourthUpdateNeeded = false;
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateBackgroundImage () {
        DispatchQueue.main.async(execute: {
            self.backgroundImageView.image = self.appDelegate.backgroundImage
        })
        
    }
    
    
    func reloadFlickrs() {
        self.imageCache?.removeAllObjects();
        flickrArray = [[String:String]]()
        let currentLocationCoordinateString = "lat="+String(appDelegate.addressCoordinate!.latitude)+"&lon="+String(appDelegate.addressCoordinate!.longitude)
        
        let format = DateFormatter.init()
        format.dateFormat = "yyyy-MM-dd"
        var components = DateComponents()
        components.month = -1
        
        let dateString = "min_taken_date=" + format.string(from: (Calendar.current as NSCalendar).date(byAdding: components, to: Date(), options: [])!)
        
        //  let dateString = "min_taken_date=" + String(year!) + "-01-01"
        //  let currentYearString
        let searchRequestString = baseUrlString + searchMethodString + "&" + currentLocationCoordinateString + "&" + formatString + "&" + dateString + "&" + apiKey + "&order=date-taken-desc&privacy_filter=1" + "&radius=" + String(radius)
        print(searchRequestString)
        
        let searchData = try? Data.init(contentsOf: URL.init(string: searchRequestString)!)
        
        
        
        if searchData != nil {
            
            
            let parser = XMLParser.init(data: searchData!)
            parser.delegate = self
            parser.parse()
            
        }
        
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        flickrCollectionView.reloadData()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "photo"{
            
            flickrArray.append(attributeDict)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAtIndexPath indexPath: IndexPath){
        let flickrCell = collectionView.cellForItem(at: indexPath) as! FlickrCollectionViewCell
        let flickr = flickrArray[(indexPath as NSIndexPath).row]
        let flickrPhotoViewController = FlickrPhotoViewController.init(nibName: "FlickrPhotoViewController", bundle: nil, id: flickr["id"]!, title: flickr["title"]!)
        
        self.present(flickrPhotoViewController, animated: true, completion: {
            flickrPhotoViewController.flickrImageView.image = flickrCell.backgroundImageView.image
            flickrPhotoViewController.backgroundImageView.image = self.backgroundImageView.image
        })
        
        
        
    }
    
    func collectionView(_ collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout,sizeForItemAtIndexPath indexPath:IndexPath) -> CGSize{
        
        return CGSize(width: self.view.frame.width*0.3, height: self.view.frame.width*0.3)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int{
        if(flickrArray.count == 0){
            noPhotosLabel.isHidden = false
        }
            
        else{
            noPhotosLabel.isHidden = true
        }
        // todo : show no pics available
        return flickrArray.count
        
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell{
        let flickrCell = collectionView.dequeueReusableCell(withReuseIdentifier: flickrCollectionViewReuseIdentifier, for: indexPath) as! FlickrCollectionViewCell
        flickrCell.backgroundImageView.image = nil
        flickrCell.isUserInteractionEnabled = false
        let flickr = flickrArray[(indexPath as NSIndexPath).row]
        
        
        let farm = flickr["farm"]!
        let server = flickr["server"]!
        let secret = flickr["secret"]!
        let id = flickr["id"]!
        
        let favortieString = baseUrlString + favoriteMethod + "&photo_id=" + id + "&" + apiKey + "&format=json&nojsoncallback=1"
        
        let ImageData = self.imageCache?.object(forKey: NSString.init(format: "%d,%d", indexPath.section,indexPath.row))
        if ImageData != nil {
            flickrCell.backgroundImageView.image = UIImage.init(data: ImageData as! Data)
        }
        else{
            
            
            let backgroundImageString = "https://farm" + farm + ".staticflickr.com/" + server + "/" + id + "_" + secret + ".jpg"
            let task = URLSession.shared.dataTask(with: URL.init(string: backgroundImageString)!, completionHandler: {(data, response, error) in
                
                let updateCell = collectionView.cellForItem(at: indexPath) as? FlickrCollectionViewCell
                if updateCell != nil && data != nil {
                    self.imageCache?.setObject(data! as NSData, forKey: NSString.init(format: "%d,%d", indexPath.section,indexPath.row))
                    
                    DispatchQueue.main.async(execute: {
                        updateCell?.backgroundImageView.image = UIImage.init(data: data!)
                        updateCell?.isUserInteractionEnabled = true
                        updateCell?.sizeToFit()
                    })
                }
                
            })
            
            task.resume()
        }
        let task2 = URLSession.shared.dataTask(with: URL.init(string: favortieString)!, completionHandler: {(data, response, error) in
            if (data != nil) {
                do{
                    let favortie = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                    
                    let dic = favortie.value(forKey: "photo") as! NSDictionary
                    let favoriteNum = dic.value(forKey: "total") as! String
                    let updateCell = collectionView.cellForItem(at: indexPath) as? FlickrCollectionViewCell
                    
                    if updateCell != nil && data != nil {
                        DispatchQueue.main.async(execute: {
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
    
    @IBAction func segmentChanged(_ sender: AnyObject) {
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
