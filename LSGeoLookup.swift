//
//  LSGeoLookup.swift
//  LSGeo
//
//  Created by Thomas Hocking on 11/18/16.
//  Copyright © 2016 Thomas Hocking. All rights reserved.
//

import Foundation


enum GeoError : Int{
    case authorizationExceptionError = 10
    case otherError = 12
    case databaseTimeoutError = 13
    case invalidParameterError = 14
    case noResultsFoundError = 15
    case duplicateExceptionError = 16
    case postalCodeNotFoundError = 17
    case dailyCreditLimitExceededError = 18
    case hourlyCreditLimitExceededError = 19
    case weeklyCreditLimitExceededError = 20
    case invalidInputError = 21
    case serverOverloadError = 22
    case serviceNotImplementedError = 23
}

protocol GeoLookupDelegate {
    
    func geoNamesLookup(handler:LSGeoLookup, networkIsActive:Bool)
    func geoNamesLookup(handler:LSGeoLookup, failedWithError:Error)
    func geoNamesLookup(handler:LSGeoLookup, geoNamesFound:[Any], totalFound:Int)
}


let findNearbyURL = "http://api.geonames.org/findNearbyJSON?lat=%.8f&lng=%.8f&style=FULL&username=%@"

let nearbyToponymsURL = "http://api.geonames.org/findNearbyJSON?lat=%.8f&lng=%.8f&maxRows=%d&radius=%.3f&style=FULL&username=%@"

let findNearbyWikipediaURL = "http://api.geonames.org/findNearbyWikipediaJSON?lat=%.8f&lng=%.8f&maxRows=%d&radius=%.3f&style=FULL&username=%@&lang=%@"

let searchURL = "http://api.geonames.org/searchJSON?q=%@&maxRows=%d&startRow=%d&lang=%@&isNameRequired=true&style=FULL&username=%@"

let nearbyPOI = "http://api.geonames.org/findNearbyPOIsOSMJSON?lat=%.8f&lng=%.8f&username=%@"

let nearbyPOIMaxRows = "http://api.geonames.org/findNearbyPOIsOSMJSON?lat=%.8f&lng=%.8f&maxRows=%d&username=%@"

let nearbyPOIRadius = "http://api.geonames.org/findNearbyPOIsOSMJSON?lat=%.8f&lng=%.8f&radius=%.3f&username=%@"

let nearbyPOIMaxAndRadius = "http://api.geonames.org/findNearbyPOIsOSMJSON?lat=%.8f&lng=%.8f&maxRows=%d&radius=%d&username=%@"

let errorDomain = "org.geonames"

class LSGeoLookup: NSObject, URLSessionDelegate{
    var dataConnection:URLSession?
    var done:Bool?
    var dataBuffer:NSMutableData?
    var userID:String?
    var delegate:GeoLookupDelegate?
    
    
    init(withUserID id:String) {
        self.userID = id
    }
    
    func findNearbyPlaceName(latitude:Double, longitude:Double){
        let urlString = String(format: findNearbyURL, latitude, longitude, self.userID!)
        self.sendRequestWithURLString(urlString: urlString, keyname: "geonames")
    }
    
    func findNearbyPlacesOfInterest(latitude:Double, longitude:Double){
        let urlString = String(format: nearbyPOI, latitude, longitude, self.userID!)
        self.sendRequestWithURLString(urlString: urlString, keyname: "poi")
    }
    
    func findNearbyPlacesOfInterest(latitude:Double, longitude:Double, maxRows:Int, radius:Int){
        let urlString = String(format: nearbyPOIMaxAndRadius, latitude, longitude, maxRows, radius, self.userID!)
        self.sendRequestWithURLString(urlString: urlString, keyname: "poi")
    }
    
    private func sendRequestWithURLString(urlString:String, keyname:String){
        let url: URL = URL(string: urlString)!
        self.done = false
        let request1: URLRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
        
        self.dataConnection = URLSession(configuration: .default)
        self.delegate?.geoNamesLookup(handler: self, networkIsActive: true)
        
        self.dataConnection?.dataTask(with: request1, completionHandler: { (data, response, error) in
                do {
                    if data != nil{
                        if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                            let geoNames:[Any] = jsonResult.object(forKey: keyname) as! [Any]
                            var total = geoNames.count
                            if (jsonResult.object(forKey: TotalResultsCountKey) != nil){
                                total = Int( (jsonResult.object(forKey: TotalResultsCountKey) as! String) )!
                            }
                            self.delegate?.geoNamesLookup(handler: self, geoNamesFound: geoNames, totalFound: total)
                            self.delegate?.geoNamesLookup(handler: self, networkIsActive: true)

                            print("ASynchronous\(jsonResult)")
                            }
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
        }).resume()
        
        
        
        
    }
    
  
    func findNearbyToponymsForLatitude(latitude:Double, longitude:Double, maxRows:Int, radius:Double){
        let urlString = String(format: nearbyToponymsURL, latitude, longitude, maxRows, radius ,self.userID!)
        self.sendRequestWithURLString(urlString: urlString, keyname: "geonames")
    }
    
    func findNearbyWikipediaForLatitude(latitude:Double, longitude:Double, maxRows:Int, radius:Double, languageCode:String){
        var langCode = languageCode
        if languageCode == ""{
            langCode = "en"
        }
        
        let urlString = String(format: nearbyToponymsURL, latitude, longitude, maxRows, radius ,self.userID!, langCode)
        //not proper keyname, see constants
        self.sendRequestWithURLString(urlString: urlString, keyname: "geonames")
    }
    
    func search(query:String, maxRows:Int, startRow:Int, languageCode:String){
        //english default
        var mRows = maxRows
        if maxRows > 1000{
            mRows = 1000
        }
        
        let escQuery = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        let urlString = String(format: searchURL, escQuery!, mRows, startRow, "en", self.userID!)
         //might be able to change keyname here too
        self.sendRequestWithURLString(urlString: urlString, keyname: "geonames")
    }
    
    func cancel(){
        let lockQueue = DispatchQueue(label: "com.lion.LockQueue")
        lockQueue.sync() {
            print("canceled")
            self.dataConnection?.invalidateAndCancel()
            done = true
        }
    }
    
    
    
}
