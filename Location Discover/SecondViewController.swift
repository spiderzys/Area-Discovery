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
var currentHour:Int?
class SecondViewController: UIViewController , ChartDelegate   {
    
    @IBOutlet weak var forecastChart: Chart!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var weatherImageView: UIImageView!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var feelTemperatureLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    

    let celsiusSymbol = "\u{00B0}C"
    let forecastRequestString = "http://api.aerisapi.com/forecasts/closest?filter=1hr&limit=12&p="
    let apiKey = "client_id=NlFypg1vJvWqzu0va8Q6f&client_secret=uPIBFJjqieCCHEaO3AIHK5XUVzroPcbKmDYATqpv"
    var periods: NSArray?
    
    var currentIndex:Int = 1;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = NSUserDefaults.standardUserDefaults()
        if(!user.boolForKey("second")){
            let alertController = UIAlertController.init(title: "Try touching the chart!", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction.init(title: "ok", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            user.setObject(true, forKey: "second")
        }
        temperatureLabel.adjustsFontSizeToFitWidth = true
        feelTemperatureLabel.adjustsFontSizeToFitWidth = true
       // locationLabel.adjustsFontSizeToFitWidth = true
       
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateBackgroundImage), name: appDelegate.backgroundImageUpdatedNotificationName, object: nil)
       forecastChart.delegate = self
  }
    
    
    func updateBackgroundImage () {
        dispatch_async(dispatch_get_main_queue(), {
            self.backgroundImageView.image = appDelegate.backgroundImage
        })
        
    }
    
    @IBAction func refresh(sender: AnyObject) {
        reloadForecast()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if(appDelegate.isLocationChanged || currentHour != getCurrentHour()){
           reloadForecast()
           showCurrentWeather(periods![0] as! NSDictionary)
           //currentPeriod = periods[0] as! NSDictionary
        }
        
        
    }
    
    func reloadForecast(){
        forecastChart.removeSeries()
        forecastChart.setNeedsDisplay()
        periods = loadForecast()
        drawForecastLineChart(periods!)
        
        
    }

    
    func getCurrentHour() -> Int {
        let currentDateTime = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Hour, fromDate: currentDateTime)
        return components.hour
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
        currentHour = getCurrentHour()

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
            
            linePoints[index] = (x:Float(currentHour!+index),y:temperature.floatValue)
            index = index + 1
            
        }
        
        forecastChart.axesColor = (appDelegate.window?.tintColor!)!
        forecastChart.labelFont = UIFont.systemFontOfSize(13)
        forecastChart.maxY = maxTemperature + 2
        forecastChart.minY = minTemperature - 2
        forecastChart.labelColor = (appDelegate.window?.tintColor!)!
        forecastChart.yLabelsOnRightSide = true
        forecastChart.highlightLineColor = UIColor.redColor()
        forecastChart.yLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
            return String(format:"%.1f%@", labelValue, self.celsiusSymbol)
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
    
    func showCurrentWeather(period:NSDictionary){
        let weatherIcon = period.valueForKey("icon") as! NSString
        weatherImageView.image = UIImage.init(named: weatherIcon as String)
        let temperature = period.valueForKey("tempC") as! NSNumber
        let feelTemperature = period.valueForKey("avgFeelslikeC") as! NSNumber
        temperatureLabel.textColor = getColorFrom(temperature.floatValue)
        feelTemperatureLabel.textColor = getColorFrom( feelTemperature.floatValue)
        
        temperatureLabel.text =  String(format: "%@%@", temperature,celsiusSymbol)
        feelTemperatureLabel.text = String(format: "Feel:%@%@",feelTemperature,celsiusSymbol)
        
        let locationString = getAddressString(appDelegate.addressDic!)
        locationLabel.text = locationString.characters.count>1 ? locationString : "Unknown Area"
        
        
        
    }
    
    
    
    
    func getColorFrom(temperature:Float) -> UIColor {
        switch temperature {
        case 35...100:
        return UIColor.redColor()
        case -100...0:
        return UIColor.blueColor()
        case 1...17:
        return UIColor(red: 70.0/255, green: 205.0/255, blue: 30.0/255,alpha: 1)
        case 30...34:
        return UIColor.orangeColor()
        case 24...29:
            return UIColor(red: 255.0/255, green: 190.0/255, blue: 70.0/255,alpha: 1)
        default:
            return (appDelegate.window?.tintColor!)!
        }
      
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        appDelegate.isLocationChanged = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func didTouchChart(chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
        if(Int(round(x)) != currentIndex){
            currentIndex = Int(round(x))
            showCurrentWeather(periods![currentIndex-1] as! NSDictionary)
        }
        
    }
    func didFinishTouchingChart(chart: Chart){
        
    }
    
    
    func getAddressString (addressDic:[String:String?]) -> String!{
        var locationInfo = ""
        if(addressDic["city"] != nil){
            locationInfo = locationInfo + addressDic["city"]!!+", "
            
        }
        if(addressDic["state"] != nil){
            locationInfo = locationInfo + addressDic["state"]!!+", "
            
        }
        if(addressDic["country"] != nil){
            locationInfo = locationInfo + addressDic["country"]!!
            
        }
        return locationInfo
    }


}

