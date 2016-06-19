//
//  SecondViewController.swift
//  Location Discover
//
//  Created by YANGSHENG ZOU on 2016-06-15.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit
import SwiftChart

let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
class SecondViewController: UIViewController   {
    
    @IBOutlet weak var forecastChart: Chart!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    let forecastRequestString = "http://api.aerisapi.com/forecasts/closest?filter=1hr&limit=12&p="
    let apiKey = "client_id=NlFypg1vJvWqzu0va8Q6f&client_secret=uPIBFJjqieCCHEaO3AIHK5XUVzroPcbKmDYATqpv"
    var currentPeriod:NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateBackgroundImage), name: appDelegate.backgroundImageUpdatedNotificationName, object: nil)
       
  }
    
    
    func updateBackgroundImage () {
        dispatch_async(dispatch_get_main_queue(), {
            self.backgroundImageView.image = appDelegate.backgroundImage
        })
        
    }
    
    @IBAction func refresh(sender: AnyObject) {
        reloadPage()
    }
    
    func reloadPage(){
        forecastChart.removeSeries()
        forecastChart.setNeedsDisplay()
        let periods = loadForecast()
        drawForecastLineChart(periods)
        currentPeriod = periods[0] as? NSDictionary
        showCurrentWeather()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if(appDelegate.isLocationChanged){
           reloadPage()
           
           //currentPeriod = periods[0] as! NSDictionary
        }
        
        
    }
    
    func loadForecast()->NSArray  {
        
        let currentLocationCoordinateString = String(appDelegate.addressCoordinate!.latitude) + ","+String(appDelegate.addressCoordinate!.longitude)
        let currentLocationForecastRequestString = forecastRequestString + currentLocationCoordinateString + "&" + apiKey
        print(currentLocationForecastRequestString)
        
        let forecastData = NSData.init(contentsOfURL: NSURL.init(string: currentLocationForecastRequestString)!)
        if forecastData != nil {
            
            do{
                let dict:NSDictionary = try NSJSONSerialization.JSONObjectWithData(forecastData!, options: []) as! NSDictionary
     
                let success = dict.valueForKey("success") as! Bool
                if(success){
                    
                    let response = dict.valueForKey("response") as! NSArray
                    return response[0].valueForKey("periods") as! NSArray
                    
          
                }
                else{
                    let error = dict.valueForKey("error")
                    return NSArray.init(object: error!)
                }
                
                }catch _ {
    
            }
            
        }
            
        else {
            print("no data")
            
        }
        return NSArray.init(object: currentLocationCoordinateString)
    }
    
    func drawForecastLineChart(periods:NSArray){
        let currentDateTime = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Hour, fromDate: currentDateTime)
        let currentHour = components.hour

        var linePoints: Array<(x: Float, y: Float)> = Array.init(count: periods.count, repeatedValue: (x: 0,y: 0))
        
        var index = 0
        var maxTemperature:Float = -99
        var minTemperature:Float = 99
        for period in periods as! [NSDictionary] {
            let temperature = period.valueForKey("tempC") as! NSNumber
            if(temperature.floatValue < minTemperature){
                minTemperature = temperature.floatValue
            }
            if(temperature.floatValue > maxTemperature){
                maxTemperature = temperature.floatValue
            }
            
            linePoints[index] = (x:Float(currentHour+index),y:temperature.floatValue)
            index = index + 1
            
        }
        
        forecastChart.axesColor = (appDelegate.window?.tintColor!)!
        forecastChart.labelFont = UIFont.systemFontOfSize(13)
        forecastChart.maxY = maxTemperature + 2
        forecastChart.minY = minTemperature - 2
        forecastChart.labelColor = (appDelegate.window?.tintColor!)!
        forecastChart.yLabelsOnRightSide = true
        forecastChart.yLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
            return String(format:"%.1f%@C", labelValue,"\u{00B0}")
        }
        
        
        forecastChart.xLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
            if(labelIndex == 0){
                return "->"
            }
            /*
            if (labelIndex == 10){
                return String(format:"%d:00", Int(labelValue)%24)
            }
 */
            
            
            return String(format:"%d", labelIndex)
        }
        forecastChart.xLabelsTextAlignment = .Left
        forecastChart.addSeries(ChartSeries(data:linePoints))
        

    }
    
    func showCurrentWeather(){
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        appDelegate.isLocationChanged = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

