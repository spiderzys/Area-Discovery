//
//  SecondViewController.swift
//  Location Discover
//
//  Created by YANGSHENG ZOU on 2016-06-15.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        print(delegate.currentCity)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

