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
    @IBOutlet weak var mapView: MKMapView!  // the mapview on the screen
    @IBOutlet weak var locationLabel: UILabel!  // shows the location
    @IBOutlet weak var searchResultTableView: UITableView! // auto complete result
    @IBOutlet weak var locationSearchBar: UISearchBar! // bar for searching
    
    var geoCoder:CLGeocoder = CLGeocoder.init()
    let locationManager = CLLocationManager.init()
    var currentLocationAnnotation = MKPointAnnotation.init()  // annotation on the map
    var searchResultPlacemarks:Array<MKMapItem>?
    let searchResultTableViewCellIdentifier = "map"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var isLocationChanged = true // determine whether location updated
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        locationSearchBar.tintColor = UIColor.blue
        for tabBarItem:UITabBarItem in self.tabBarController!.tabBar.items! {
            tabBarItem.isEnabled = false
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
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse){
            // if location is good
            
            showHint()

            locationManager.startUpdatingLocation();
        }
            
        else{
            locationManager.requestWhenInUseAuthorization()
            
        }
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus){
        // when location authorization has been updated
        if(status == CLAuthorizationStatus.authorizedAlways || status == CLAuthorizationStatus.authorizedWhenInUse){
            showHint()
            

            locationManager.startUpdatingLocation();
           
        }
    }
    
    func showHint(){
        
        // for first time user, show hint
        let user = UserDefaults.standard
        if(!user.bool(forKey: "first")){
            self.showAlert("long press on the map to change the location")
            user.set(true, forKey: "first")
        }

    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last
       
        mapView.setCenter((currentLocation?.coordinate)!, animated: true)
        showLocation((currentLocation?.coordinate)!)
        manager.stopUpdatingLocation()
       
        longPressGesture.isEnabled = true
        
    }
   
    
    func showLocation(_ coordinate:CLLocationCoordinate2D){
        
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
                
                let addressString = self.getAddressString(addressDic!)
                if((addressString?.characters.count)! > 1){
                    self.locationLabel.text =   self.getAddressString(addressDic!)
                }
                else {
                    self.locationLabel.text = "unknown area"
                }
            }
            else{
                print(error!)
            }
            for tabBarItem:UITabBarItem in self.tabBarController!.tabBar.items! {
                tabBarItem.isEnabled = true
            }
        })
       
    }
    
    func getAddressFrom(_ placemark:CLPlacemark) -> [String:String?]! {
        // get address dic from placemark
        let addressDic:[String:String?] = ["city":placemark.locality,"state":placemark.administrativeArea,"country":placemark.country]
        return addressDic
        
    }
    
    
    @IBAction func coordinateMove(_ sender: AnyObject) {
        
        // when user specifies a new coordinate
        locationSearchBar.endEditing(true)
        let touchPoint = longPressGesture.location(ofTouch: 0, in: mapView)
        
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        currentLocationAnnotation.coordinate = touchMapCoordinate
        longPressGesture.isEnabled = false
        mapView.region.center = touchMapCoordinate
        showLocation(touchMapCoordinate)
        longPressGesture.isEnabled = true
    }
    
    @IBAction func returnToUserLocation(_ sender: AnyObject) {
        
        longPressGesture.isEnabled = false
        locationManager.startUpdatingLocation();
        
    }
    
    func searchBarTextDidEndEditing( _ searchBar: UISearchBar){
        self.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        
        if(searchBar.text != nil){
            geoCoder.geocodeAddressString(searchBar.text!, completionHandler: {(placemarks:Array<CLPlacemark>?, error:NSError?) in
                
                //   self.searchResultPlacemarks = placemarks
                if (error != nil){
                    super.showAlert("No matching location returned")
                }
                else{
                    self.showSearchResultFrom(placemarks!.first!)
                }
            } as! CLGeocodeCompletionHandler)
        }
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar,textDidChange searchText: String){
        
        // when search bar is being edited, get new search result
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.region = MKCoordinateRegionForMapRect(MKMapRectWorld)
        localSearchRequest.naturalLanguageQuery = searchBar.text
        let localSearch = MKLocalSearch(request: localSearchRequest)
        
        localSearch.start { (localSearchResponse, error) -> Void in
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
    
    func showSearchResultFrom(_ placemark:CLPlacemark){
        
        
        // get the location of selected placemark
        self.mapView.region.center = (placemark.location?.coordinate)!
        
        self.searchResultPlacemarks = nil;
        
        self.searchResultTableView.reloadData()
        
        showLocation((placemark.location?.coordinate)!)
    }
    
    
    //-----------------------tableview delegate and datasource----------------------------
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int{
        if (searchResultPlacemarks == nil){
            return 0
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat{
        return self.view.frame.height * 0.05
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell{
        var locationCell = tableView.dequeueReusableCell(withIdentifier: searchResultTableViewCellIdentifier)
        if(locationCell == nil) {
            locationCell = UITableViewCell.init(style: .default, reuseIdentifier: searchResultTableViewCellIdentifier)
            
        }
        let placemark = searchResultPlacemarks![(indexPath as NSIndexPath).row].placemark
        locationCell?.textLabel?.text = super.getAddressString(getAddressFrom(placemark))
        
        return locationCell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath){
        locationSearchBar.endEditing(true)
        showSearchResultFrom(searchResultPlacemarks![(indexPath as NSIndexPath).row].placemark)
        
    }
   
    // ----------------------------------end------------------------------------------
    
    
    override func viewWillDisappear(_ animated: Bool) {
               takeSnapShot()
               super.viewWillDisappear(animated)
    }
    
    func takeSnapShot(){
        
        // take snapshot as background image
        let options = MKMapSnapshotOptions()
        options.region = mapView.region
        options.scale = UIScreen.main.scale
        options.size = mapView.frame.size;
        options.showsPointsOfInterest = true
        
        let snapShotter = MKMapSnapshotter.init(options: options)
        
        //  let semaphore = dispatch_semaphore_create(0);
        
        if(isLocationChanged){
            self.isLocationChanged = false
            
            
            snapShotter.start(with: DispatchQueue.main, completionHandler: {(snapshot, error) -> Void in
                if(error == nil){
                    self.appDelegate.backgroundImage = snapshot?.image
                    NotificationCenter.default.post(name: Notification.Name(rawValue: self.appDelegate.backgroundImageUpdatedNotificationName), object: nil)
                    
                }
                
            } )
        }

    }
    
    
}

