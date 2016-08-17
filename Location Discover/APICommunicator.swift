//
//  APICommunicator.swift
//  Location Discover
//
//  Created by YANGSHENG ZOU on 2016-08-16.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit

class APICommunicator: NSObject {

    // -------------------for singleton pattern------------------
    private static let singleton = APICommunicator()
    
    private override init(){
        // set init private to make it singleton
        
    }
    
    static func sharedInstance() -> APICommunicator {
        // the only method to get singleton
        return singleton
    }
    // -------------------- end-------------------------------------
    
    
    internal func requestForecastAPI(forecastRequestUrl:NSURL) -> NSData?{
        return NSData.init(contentsOfURL: forecastRequestUrl)
    }
    
    
    
    
    
}
