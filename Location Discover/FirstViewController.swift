//
//  FirstViewController.swift
//  Location Discover
//
//  Created by YANGSHENG ZOU on 2016-06-15.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit
import MapKit

class FirstViewController: ViewController,CLLocationManagerDelegate {
    
    @IBOutlet var longPressGesture: UILongPressGestureRecognizer!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var searchResultTableView: UITableView!
    @IBOutlet weak var locationSearchBar: UISearchBar!
    
    var geoCoder:CLGeocoder = CLGeocoder.init()
    let locationManager = CLLocationManager.init()
    var currentLocationAnnotation = MKPointAnnotation.init()
    var searchResultPlacemarks:Array<MKMapItem>?
    let searchResultTableViewCellIdentifier = "map"
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var isLocationChanged = true
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        locationSearchBar.tintColor = UIColor.blueColor()
        for tabBarItem:UITabBarItem in self.tabBarController!.tabBar.items! {
            tabBarItem.enabled = false
        }
        // ---------------- inital location manager -----------------
        appDelegate.window?.tintColor = locationLabel.textColor
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        mapView.region.span = MKCoordinateSpan.init(latitudeDelta: 4, longitudeDelta: 4)
        
        activeLocationManagerAuthorization()
        
        //---------------------------end---------------------
        mapView.addAnnotation(currentLocationAnnotation)
    
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func activeLocationManagerAuthorization() {
        // check authorization of location
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse){
            // if location is good
            
            showHint()

            locationManager.startUpdatingLocation();
        }
            
        else{
            locationManager.requestWhenInUseAuthorization()
            
        }
        
        
        
    }
    
    func locationManager(manager: CLLocationManager,
                         didChangeAuthorizationStatus status: CLAuthorizationStatus){
        // when location authorization has been updated
        if(status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse){
            showHint()
            

            locationManager.startUpdatingLocation();
           
        }
    }
    
    func showHint(){
        
        // for first time user, show hint
        let user = NSUserDefaults.standardUserDefaults()
        if(!user.boolForKey("first")){
            self.showAlert("long press on the map to change the location")
            user.setObject(true, forKey: "first")
        }

    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last
       
        mapView.setCenterCoordinate((currentLocation?.coordinate)!, animated: true)
        showLocation((currentLocation?.coordinate)!)
        manager.stopUpdatingLocation()
       
        longPressGesture.enabled = true
        
    }
   
    
    func showLocation(coordinate:CLLocationCoordinate2D){
        
        // show the information of selected coordinate
        
        
        appDelegate.addressCoordinate = coordinate
        isLocationChanged = true
        appDelegate.isSecondUpadateNeeded = true
        appDelegate.isThirdUpadateNeeded = true
        appDelegate.isFourthUpdateNeeded = true
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        //print(location)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { placemark,error in
            
            if error == nil {
                let addressDic = self.getAddressFrom((placemark?.last)!)
                
                self.appDelegate.addressDic = addressDic
                
                let addressString = self.getAddressString(addressDic)
                if(addressString.characters.count > 1){
                    self.locationLabel.text =   self.getAddressString(addressDic)
                }
                else {
                    self.locationLabel.text = "unknown area"
                }
            }
            else{
                print(error!)
            }
            for tabBarItem:UITabBarItem in self.tabBarController!.tabBar.items! {
                tabBarItem.enabled = true
            }
        })
       
    }
    
    func getAddressFrom(placemark:CLPlacemark) -> [String:String?]! {
        // get address dic from placemark
        let addressDic:[String:String?] = ["city":placemark.locality,"state":placemark.administrativeArea,"country":placemark.country]
        return addressDic
        
    }
    
    
    @IBAction func coordinateMove(sender: AnyObject) {
        
        // when user specifies a new coordinate
        locationSearchBar.endEditing(true)
        let touchPoint = longPressGesture.locationOfTouch(0, inView: mapView)
        
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        currentLocationAnnotation.coordinate = touchMapCoordinate
        longPressGesture.enabled = false
        mapView.region.center = touchMapCoordinate
        showLocation(touchMapCoordinate)
        longPressGesture.enabled = true
    }
    
    @IBAction func returnToUserLocation(sender: AnyObject) {
        
        longPressGesture.enabled = false
        locationManager.startUpdatingLocation();
        
    }
    
    func searchBarTextDidEndEditing( searchBar: UISearchBar){
        self.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        
        if(searchBar.text != nil){
            geoCoder.geocodeAddressString(searchBar.text!, completionHandler: {(placemarks:Array<CLPlacemark>?, error:NSError?) in
                
                //   self.searchResultPlacemarks = placemarks
                if (error != nil){
                    super.showAlert("No matching location returned")
                }
                else{
                    self.showSearchResultFrom(placemarks!.first!)
                }
            })
        }
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar){
        searchBar.endEditing(true)
    }
    
    func searchBar(searchBar: UISearchBar,textDidChange searchText: String){
        
        // when search bar is being edited, get new search result
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.region = MKCoordinateRegionForMapRect(MKMapRectWorld)
        localSearchRequest.naturalLanguageQuery = searchBar.text
        let localSearch = MKLocalSearch(request: localSearchRequest)
        
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            self.searchResultPlacemarks = nil
            
            if localSearchResponse != nil{
               
                self.searchResultPlacemarks = localSearchResponse?.mapItems
            }
            
            self.searchResultTableView.reloadData()
        }
        
        
        /*  geoCoder.geocodeAddressString(searchText, completionHandler: {(placemarks:Array<CLPlacemark>?, error:NSError?) in
         if error == nil {
         self.searchResultPlacemarks = placemarks
         self.searchResultTableView.reloadData()
         }
         })
         */
    }
    
    func showSearchResultFrom(placemark:CLPlacemark){
        
        
        // get the location of selected placemark
        self.mapView.region.center = (placemark.location?.coordinate)!
        
        self.searchResultPlacemarks = nil;
        
        self.searchResultTableView.reloadData()
        
        showLocation((placemark.location?.coordinate)!)
    }
    
    
    //-----------------------tableview delegate and datasource----------------------------
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        if (searchResultPlacemarks == nil){
            return 0
        }
        else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1
    }
    
    func tableView(tableView: UITableView,
                   heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return self.view.frame.height * 0.05
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var locationCell = tableView.dequeueReusableCellWithIdentifier(searchResultTableViewCellIdentifier)
        if(locationCell == nil) {
            locationCell = UITableViewCell.init(style: .Default, reuseIdentifier: searchResultTableViewCellIdentifier)
            
        }
        let placemark = searchResultPlacemarks![indexPath.row].placemark
        locationCell?.textLabel?.text = super.getAddressString(getAddressFrom(placemark))
        
        return locationCell!
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        locationSearchBar.endEditing(true)
        showSearchResultFrom(searchResultPlacemarks![indexPath.row].placemark)
        
    }
   
    // ----------------------------------end------------------------------------------
    
    
    override func viewWillDisappear(animated: Bool) {
               takeSnapShot()
               super.viewWillDisappear(animated)
    }
    
    func takeSnapShot(){
        
        // take snapshot as background image
        let options = MKMapSnapshotOptions()
        options.region = mapView.region
        options.scale = UIScreen.mainScreen().scale
        options.size = mapView.frame.size;
        options.showsPointsOfInterest = true
        
        let snapShotter = MKMapSnapshotter.init(options: options)
        
        //  let semaphore = dispatch_semaphore_create(0);
        
        if(isLocationChanged){
            self.isLocationChanged = false
            
            snapShotter.startWithQueue(dispatch_get_main_queue(), completionHandler: {(snapshot:MKMapSnapshot?, error:NSError?)  in
                if(error == nil){
                    self.appDelegate.backgroundImage = snapshot?.image
                    NSNotificationCenter.defaultCenter().postNotificationName(self.appDelegate.backgroundImageUpdatedNotificationName, object: nil)
                    
                }
                
            })
        }

    }
    
    
}

