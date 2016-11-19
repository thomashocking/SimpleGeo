//
//  ViewController.swift
//  LSGeo
//
//  Created by Thomas Hocking on 11/18/16.
//  Copyright © 2016 Thomas Hocking. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GeoLookupDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userName = ""
        let geocoder = LSGeoLookup(withUserID: userName)
        geocoder.delegate = self
        
        //geocoder.findNearbyPlaceName(latitude: 43.0389, longitude: -87.9065)
        //geocoder.cancel()
        //geocoder.findNearbyPlacesOfInterest(latitude: 43.0389, longitude: -87.9065, maxRows:10, radius:1)
       // geocoder.findNearbyWikipediaForLatitude(latitude: 43.0389, longitude: -87.9065, maxRows: 1, radius: 1, languageCode: "en")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func geoNamesLookup(handler:LSGeoLookup, networkIsActive:Bool){
        print(networkIsActive)
    }
    func geoNamesLookup(handler:LSGeoLookup, failedWithError:Error){
        print(failedWithError)
    }
    func geoNamesLookup(handler:LSGeoLookup, geoNamesFound:[Any], totalFound:Int){
        print("found: " + "\(totalFound)")
    }
}

