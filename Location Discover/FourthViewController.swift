//
//  FourthViewController.swift
//  Location Discover
//
//  Created by YANGSHENG ZOU on 2016-06-21.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit

class FourthViewController: UIViewController {
    
    @IBOutlet weak var radiusSegmentedControl: UISegmentedControl!

    @IBOutlet weak var flickrCollectionView: UICollectionView!
    
    let flickrCollectionViewReuseIdentifier = "flickr"
    var radius = 1
    var instagrams : NSArray?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let baseUrlString = "https://api.flickr.com/services/rest/?"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flickrCollectionView.registerNib(UINib.init(nibName: "flickrCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: flickrCollectionViewReuseIdentifier)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if appDelegate.isFourthUpdateNeeded {
            reloadFlickrs()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func reloadFlickrs() {
        
    }
    
    func collectionView(collectionView: UICollectionView,
                          didSelectItemAtIndexPath indexPath: NSIndexPath){
        
    }
    
    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int{
        if (instagrams == nil){
            return 0
        }
        else {
            return instagrams!.count
        }
        
    }
    func collectionView(collectionView: UICollectionView,
                          cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let flickCell = collectionView.dequeueReusableCellWithReuseIdentifier(flickrCollectionViewReuseIdentifier, forIndexPath: indexPath)
        
        return flickCell
    }
    
    @IBAction func segmentChanged(sender: AnyObject) {
        switch radiusSegmentedControl.selectedSegmentIndex {
        case 0:
            radius = 1
        case 1:
            radius = 5
        case 2:
            radius = 10
        default:
            radius = 30
        }
        reloadFlickrs()
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
