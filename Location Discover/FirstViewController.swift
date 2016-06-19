//
//  FirstViewController.swift
//  Location Discover
//
//  Created by YANGSHENG ZOU on 2016-06-15.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit
import MapKit

class FirstViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        for tabBarItem:UITabBarItem in self.tabBarController!.tabBar.items! {
            tabBarItem.enabled = false
        }
        
        appDelegate.window?.tintColor = locationLabel.textColor
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        mapView.region.span = MKCoordinateSpan.init(latitudeDelta: 4, longitudeDelta: 4)
      //  activeLocationManagerAuthorization()
        mapView.addAnnotation(currentLocationAnnotation)
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func activeLocationManagerAuthorization() {
        
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse){
            
            locationManager.startUpdatingLocation();
            
            
        }
            
        else{
            locationManager.requestWhenInUseAuthorization()
        }
        
        
        
    }
    
    func locationManager(manager: CLLocationManager,
                         didChangeAuthorizationStatus status: CLAuthorizationStatus){
        
        if(status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse){
            
            locationManager.startUpdatingLocation();
            // next step
            
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last
        mapView.setCenterCoordinate((currentLocation?.coordinate)!, animated: true)
        showLocation((currentLocation?.coordinate)!)
        manager.stopUpdatingLocation()
       

        tapGestureRecognizer.enabled = true
        
        
        
    }
    
    
    
    func showLocation(coordinate:CLLocationCoordinate2D){
        appDelegate.addressCoordinate = coordinate
        appDelegate.isLocationChanged = true
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        //print(location)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { placemark,error in
            
            if error == nil {
                let addressDic = self.getAddressFrom((placemark?.last)!)
                
                self.appDelegate.addressDic = addressDic
                
                let addressString = self.getAddressString(addressDic)
                if(addressString.characters.count > 1){
                    self.locationLabel.text = "Tap to change: \n" + self.getAddressString(addressDic)
                }
                else {
                    self.locationLabel.text = "Tap to change: \n" + "unknown area"
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
    
    func getAddressFrom(placemark:CLPlacemark) -> [String:String?] {
        
        let addressDic:[String:String?] = ["country":placemark.country,"state":placemark.administrativeArea,"city":placemark.locality]
        return addressDic
        
    }
    
    func getAddressString (addressDic:[String:String?]) -> String!{
        var locationInfo = ""
        for entry in addressDic.values {
            if(entry != nil){
                locationInfo = locationInfo + entry! + " "
            }
        }
        return locationInfo
    }
    
    @IBAction func coordinateMove(sender: AnyObject) {
        locationSearchBar.endEditing(true)
        let touchPoint = tapGestureRecognizer.locationOfTouch(0, inView: mapView)
        
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        currentLocationAnnotation.coordinate = touchMapCoordinate
        
        mapView.region.center = touchMapCoordinate
        showLocation(touchMapCoordinate)
    }
    /*
     func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
     mapView.userInteractionEnabled = false
     }
      */
     func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
     
     }
    
    
    
    @IBAction func returnToUserLocation(sender: AnyObject) {
        
        tapGestureRecognizer.enabled = false
        locationManager.startUpdatingLocation();
         print(mapView.region)
    }
    
    func searchBarTextDidEndEditing( searchBar: UISearchBar){
        self.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        if(searchBar.text != nil){
            geoCoder.geocodeAddressString(searchBar.text!, completionHandler: {(placemarks:Array<CLPlacemark>?, error:NSError?) in
                
                //   self.searchResultPlacemarks = placemarks
                if (error != nil){
                    let alertController = UIAlertController.init(title: "No results return", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    let cancelAction = UIAlertAction.init(title: "ok", style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                else{
                    self.showSearchResultFrom(placemarks!.first!)
                }
            })
        }
    }
    
    
    func searchBar(searchBar: UISearchBar,textDidChange searchText: String){
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.region = MKCoordinateRegionForMapRect(MKMapRectWorld)
        localSearchRequest.naturalLanguageQuery = searchBar.text
        let localSearch = MKLocalSearch(request: localSearchRequest)
        
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            self.searchResultPlacemarks = nil
            
            if localSearchResponse != nil{
                print(localSearchResponse)
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
        locationCell?.textLabel?.text = getAddressString(getAddressFrom(placemark))
        
        return locationCell!
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        showSearchResultFrom(searchResultPlacemarks![indexPath.row].placemark)
        
        
    }
    
    
    
    override func viewWillDisappear(animated: Bool) {
        
        let options = MKMapSnapshotOptions()
        options.region = mapView.region
       // options.region = CLRegion.init()
        print(options.region)
        options.scale = UIScreen.mainScreen().scale
        options.size = mapView.frame.size;
        options.showsPointsOfInterest = true
        
        let snapShotter = MKMapSnapshotter.init(options: options)
        
        //  let semaphore = dispatch_semaphore_create(0);
       
        if(appDelegate.isLocationChanged){
            
            snapShotter.startWithQueue(dispatch_get_main_queue(), completionHandler: {(snapshot:MKMapSnapshot?, error:NSError?)  in
                if(error == nil){
                    self.appDelegate.backgroundImage = snapshot?.image
                    NSNotificationCenter.defaultCenter().postNotificationName(self.appDelegate.backgroundImageUpdatedNotificationName, object: nil)
                    
                    
                    
                }
                
                //  dispatch_semaphore_signal(semaphore);
                
            })
        }
        super.viewWillDisappear(animated)
    }
    
}

