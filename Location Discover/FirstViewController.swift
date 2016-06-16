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
    
    var geoCoder:CLGeocoder = CLGeocoder.init()
    let locationManager = CLLocationManager.init()

    override func viewDidLoad() {
        
        super.viewDidLoad()
       
                
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        mapView.region.span = MKCoordinateSpan.init(latitudeDelta: 5, longitudeDelta: 5)
        activeLocationManagerAuthorization()
        
        
        
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
                var locationInfo = "Tap to change: \n"
                let delegate = UIApplication.sharedApplication().delegate as! AppDelegate

                for p:CLPlacemark in placemark!{
                    if(p.country != nil){
                        locationInfo = locationInfo+p.country!+" "
                        delegate.currentCountry = p.country
                    }
                    else {
                        delegate.currentCountry = nil
                    }
                    
                    if(p.administrativeArea != nil){
                        locationInfo = locationInfo+p.administrativeArea!+" "
                        delegate.currentState = p.administrativeArea
                    }
                    
                    else{
                        delegate.currentState = nil
                    }      
                    
                    if(p.locality != nil){
                        locationInfo = locationInfo+p.locality!+" "
                       
                        delegate.currentCity = p.locality
                        
                    }
                    
                    else{
                         delegate.currentCity = nil
                    }
                    self.locationLabel.text = locationInfo
                    
                }
            }
            else{
                print(error!)
            }
        })
        
    }
    
    @IBAction func coordinateMove(sender: AnyObject) {
        let touchPoint = tapGestureRecognizer.locationOfTouch(0, inView: mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
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

