//
//  ViewController.swift
//  Location Discover
//
//  Created by YANGSHENG ZOU on 2016-06-20.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func showAlert(message:String) {
        
        
            let alertController = UIAlertController.init(title: message, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction.init(title: "ok", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        
        

    }
    
    func getAddressString (addressDic:[String:String?]) -> String!{
        var locationInfo = ""
        if(addressDic["city"]! != nil){
            locationInfo = locationInfo + addressDic["city"]!!+", "
            
        }
        if(addressDic["state"]! != nil){
            locationInfo = locationInfo + addressDic["state"]!!+", "
            
        }
        if(addressDic["country"]! != nil){
            locationInfo = locationInfo + addressDic["country"]!!
            
        }
        return locationInfo
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
