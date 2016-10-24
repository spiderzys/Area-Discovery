//
//  DataProcessor.swift
//  Location Discover
//
//  Created by YANGSHENG ZOU on 2016-08-16.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit

class DataProcessor: NSObject {
    // the class receives and processs data from APICommunicator. it is a data provider to view controller as well
    
    
    // -----------------------for singleton ---------------------------
    
    fileprivate static let singleton = DataProcessor()
    
    fileprivate override init(){
        // set init private to make it singleton
        
    }
    
    static func sharedInstance() -> DataProcessor {
        // the only method to get singleton
        return singleton
    }
    
    //----------------------end-------------------------------------
    
    func getForecastData(_ forecastRequestUrl:URL) -> NSArray? {
        let forecastData = APICommunicator.sharedInstance().requestForecastAPI(forecastRequestUrl)
        
        if forecastData != nil {
            
            do{
                let dict:NSDictionary = try JSONSerialization.jsonObject(with: forecastData!, options: []) as! NSDictionary
                
                let success = dict.value(forKey: "success") as! Bool
                if(success){
                    
                    let response = dict.value(forKey: "response") as! NSArray
                    return (response[0] as AnyObject).value(forKey: "periods") as? NSArray
                    
                    
                }
                else{
                    let error = dict.value(forKey: "error")
                    return NSArray.init(object: error!)
                }
                
            }catch _ {
                
            }
            
        }
            
    
        return nil
        
        
        
        
    }
    
    
    
    
    
    
}
