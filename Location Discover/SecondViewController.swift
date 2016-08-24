//
//  SecondViewController.swift
//  Location Discover
//
//  Created by YANGSHENG ZOU on 2016-06-15.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit
import SwiftChart

class SecondViewController: ViewController , ChartDelegate   {
    static var isUpdateNeed = true
    
    @IBOutlet weak var forecastChart: Chart!  // line chart for temperature
    
    @IBOutlet weak var backgroundImageView: UIImageView!  // background imageview
    
    @IBOutlet weak var weatherImageView: UIImageView!   // show current weather
    
    @IBOutlet weak var temperatureLabel: UILabel!   // show temperature
    
    @IBOutlet weak var feelTemperatureLabel: UILabel! // show feel temperature
    
    @IBOutlet weak var locationLabel: UILabel!  // show specified location
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let celsiusSymbol = "\u{00B0}C"
    let forecastRequestString = "http://api.aerisapi.com/forecasts/closest?filter=1hr&limit=12&p="// forecast request url string
    let apiKey = "client_id=NlFypg1vJvWqzu0va8Q6f&client_secret=uPIBFJjqieCCHEaO3AIHK5XUVzroPcbKmDYATqpv"  // your own cliend-id and secret
    var periods: NSArray?   //
    
    var currentIndex:Int = 0;  // show current period index in the line chart
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = NSUserDefaults.standardUserDefaults()
        if(!user.boolForKey("second")){
            self.showAlert("try touching the chart")
            user.setObject(true, forKey: "second")
        }
        // give clue when it is the first time of usage
        
        temperatureLabel.adjustsFontSizeToFitWidth = true
        feelTemperatureLabel.adjustsFontSizeToFitWidth = true
       
       
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateBackgroundImage), name: appDelegate.backgroundImageUpdatedNotificationName, object: nil)
       forecastChart.delegate = self
  }
    
    
    func updateBackgroundImage () {
        // update background image
        dispatch_async(dispatch_get_main_queue(), {
            self.backgroundImageView.image = self.appDelegate.backgroundImage
        })
        
    }
    
   
    
    @IBAction func refresh(sender: AnyObject) {
        
        reloadForecast()
        showAlert("refreshing done")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if(appDelegate.isSecondUpadateNeeded){
           backgroundImageView.image = appDelegate.backgroundImage
            //periods = nil
           reloadForecast()
           
        }
        
    }
    
    func reloadForecast(){
        
        
        forecastChart.removeSeries()
        forecastChart.setNeedsDisplay()
        let currentLocationCoordinateString = String(appDelegate.addressCoordinate!.latitude) + ","+String(appDelegate.addressCoordinate!.longitude)
        let currentLocationForecastRequestString = forecastRequestString + currentLocationCoordinateString + "&" + apiKey
        // print(currentLocationForecastRequestString)
        
      

        periods = DataProcessor.sharedInstance().getForecastData(NSURL.init(string: currentLocationForecastRequestString)!)
        if(periods != nil){
            if(periods?.count == 12 ){
                drawForecastLineChart()
            //    print(periods![0])
                showCurrentWeather(periods![0] as! NSDictionary)
            }
        }
        
        else {
            showAlert("No network")
        }
        
    }

    
    
    
        
    func drawForecastLineChart(){
       // currentHour = getCurrentHour()
        // draw the chart line for the
        var linePoints: Array<(x: Float, y: Float)> = Array.init(count: periods!.count, repeatedValue: (x: 0,y: 0))
        
        var index = 0
        var maxTemperature:Float = -99
        var minTemperature:Float = 99
        for period in periods as! [NSDictionary] {
            // get the max and min temperature during the period
            let temperature = period.valueForKey("tempC") as! NSNumber
            if(temperature.floatValue < minTemperature){
                minTemperature = temperature.floatValue
            }
            if(temperature.floatValue > maxTemperature){
                maxTemperature = temperature.floatValue
            }
            
            linePoints[index] = (x:Float(index),y:temperature.floatValue)
            index = index + 1
            
        }
        
        forecastChart.axesColor = (appDelegate.window?.tintColor!)! // custom axis color
        forecastChart.labelFont = UIFont.systemFontOfSize(13)  // custom text size
        forecastChart.maxY = maxTemperature + 2
        forecastChart.minY = minTemperature - 2  // min and max Y(temperature) for line chart
        forecastChart.labelColor = (appDelegate.window?.tintColor!)!  // custom text color
        forecastChart.yLabelsOnRightSide = true   // set Y axis on the right
        forecastChart.highlightLineColor = UIColor.redColor() // set the color of axies shows user specified period
        forecastChart.yLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
            return String(format:"%.1f%@", labelValue, self.celsiusSymbol)
        }
        // the format of value on Y
        
        forecastChart.xLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
            if(labelIndex == 0){
                return "->"
            }
        // the format of value on X
            
            
            return String(format:"%d", labelIndex)
        }
        forecastChart.xLabelsTextAlignment = .Left
        forecastChart.addSeries(ChartSeries(data:linePoints))
        

    }
    
    func showCurrentWeather(period:NSDictionary){
        
        // custome the labels for a speicified period
        let weatherIcon = period.valueForKey("icon") as! NSString
        weatherImageView.image = UIImage.init(named: weatherIcon as String)
        let temperature = period.valueForKey("tempC") as! NSNumber
        let feelTemperature = period.valueForKey("avgFeelslikeC") as! NSNumber
        temperatureLabel.textColor = getColorFrom(temperature.floatValue)
        feelTemperatureLabel.textColor = getColorFrom( feelTemperature.floatValue)
        
        temperatureLabel.text =  String(format: "%@%@", temperature,celsiusSymbol)
        feelTemperatureLabel.text = String(format: "Feel:%@%@",feelTemperature,celsiusSymbol)
        
        let locationString = super.getAddressString(appDelegate.addressDic!)
        locationLabel.text = locationString.characters.count>1 ? locationString : "Unknown Area"
        
        
        
    }
    
    
    
    
    func getColorFrom(temperature:Float) -> UIColor {
        // the lable text color will change for different temperature range
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
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
     //   currentHour = currentHour! + 1
        appDelegate.isSecondUpadateNeeded = false
    }
        
    
    
    
    
    func didTouchChart(chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
        
        // the mehtod when user move the axis of the chart
        if(Int(round(x)) != currentIndex){
            currentIndex = Int(round(x))
            showCurrentWeather(periods![currentIndex] as! NSDictionary)
        }
        
    }
    func didFinishTouchingChart(chart: Chart){
        
    }
    
    
    

}

