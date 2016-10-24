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
    fileprivate static let singleton = APICommunicator()
    
    fileprivate override init(){
        // set init private to make it singleton
        
    }
    
    static func sharedInstance() -> APICommunicator {
        // the only method to get singleton
        return singleton
    }
    // -------------------- end-------------------------------------
    
    
    internal func requestForecastAPI(_ forecastRequestUrl:URL) -> Data?{
        return (try? Data.init(contentsOf: forecastRequestUrl))
    }
    
    
    
    
    
}
