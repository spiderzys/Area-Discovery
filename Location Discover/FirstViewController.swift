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
    var searchResultPlacemarks:Array<CLPlacemark>?
    let searchResultTableViewCellIdentifier = "map"
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        mapView.region.span = MKCoordinateSpan.init(latitudeDelta: 5, longitudeDelta: 5)
        activeLocationManagerAuthorization()
        mapView.addAnnotation(currentLocationAnnotation)
       
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func activeLocationManagerAuthorization() {
        
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse){
            // moveCenterTo(mapView.userLocation.coordinate)
            // next step
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
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        print(location)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { placemark,error in
            
            if error == nil {
                let addressDic = self.getAddressFrom((placemark?.last)!)
                let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                delegate.addressDic = addressDic
                self.locationLabel.text = "Tap to change: \n" + self.getAddressString(addressDic)
            }
            else{
                print(error!)
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
     
     func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
     
     
     
     mapView.userInteractionEnabled = true
     
     
     
     }
     */
    @IBAction func returnToUserLocation(sender: AnyObject) {
        
        tapGestureRecognizer.enabled = false
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
        geoCoder.geocodeAddressString(searchText, completionHandler: {(placemarks:Array<CLPlacemark>?, error:NSError?) in
            if error == nil {
                self.searchResultPlacemarks = placemarks
                self.searchResultTableView.reloadData()
            }
        })
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
            return searchResultPlacemarks!.count
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var locationCell = tableView.dequeueReusableCellWithIdentifier(searchResultTableViewCellIdentifier)
        if(locationCell == nil) {
            locationCell = UITableViewCell.init(style: .Default, reuseIdentifier: searchResultTableViewCellIdentifier)
        }
        let placemark = searchResultPlacemarks![indexPath.row]
        locationCell?.textLabel?.text = getAddressString(getAddressFrom(placemark))
        
        return locationCell!
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        showSearchResultFrom(searchResultPlacemarks![indexPath.row])
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let options = MKMapSnapshotOptions.init()
        options.region = mapView.region;
        // options.scale = [UIScreen mainScreen].scale;
        options.size = mapView.frame.size;
        
        let snapShotter = MKMapSnapshotter.init()
        snapShotter.startWithQueue(dispatch_get_main_queue(), completionHandler: {(snapshot:MKMapSnapshot?, error:NSError?)  in
            //   let backgroundImage = snapshot?.image
            //    let secondViewController = self.tabBarController?.viewControllers![2]
            //     let thirdViewController = self.tabBarController?.viewControllers![3]
            
        })
        
        
    }
    
}

