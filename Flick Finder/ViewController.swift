//
//  ViewController.swift
//  Flick Finder
//
//  Created by Christopher Burgess on 5/25/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

     @IBOutlet weak var flickImage: UIImageView!
     @IBOutlet weak var searchTextField: UITextField!
     @IBOutlet weak var latTextField: UITextField!
     @IBOutlet weak var longTextField: UITextField!
     @IBOutlet weak var imageTitle: UILabel!
     @IBOutlet weak var placeholderLabel: UILabel!
     @IBOutlet weak var searchForImageLabel: UILabel!
     
     let BASE_URL = "https://api.flickr.com/services/rest/"
     
     
     
     @IBAction func searchTextButtonTouchUp(sender: AnyObject) {
          

          
          
          let keyValuePairs = [
               "method": "flickr.photos.search",
               "api_key": "f23a3195f2fb63a93781aeb1421f26b4",
               "text": "baby+asian+elephant",
               "safe_search": "1",
               "extras": "url_m",
               "format": "json",
               "nojsoncallback": "1"
          ]
          
          getImageFromFlickrBySearch(keyValuePairs)
          
          
     }
     
     @IBAction func searchLatLongButtonTouchUp(sender: AnyObject) {
          
     }
     
     
     override func viewDidLoad() {
          super.viewDidLoad()
          // Do any additional setup after loading the view, typically from a nib.
     }

     override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
          // Dispose of any resources that can be recreated.
     }

     func getImageFromFlickrBySearch(methodArguments: [String : AnyObject]) {
          
          /* 3 - Get the shared NSURLSession to faciliate network activity */
          let session = NSURLSession.sharedSession()
          
          /* 4 - Create the NSURLRequest using properly escaped URL */
          let urlString = BASE_URL + escapedParameters(methodArguments)
          let url = NSURL(string: urlString)!
          let request = NSURLRequest(URL: url)
          
          /* 5 - Create NSURLSessionDataTask and completion handler */
          let task = session.dataTaskWithRequest(request) {data, response, downloadError in
               if let error = downloadError {
                    println("Could not complete the request \(error)")
               } else {
                    var parsingError: NSError? = nil
                    let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                    println(parsedResult.valueForKey("photos"))
               }
          }
          
          /* 6 - Resume (execute) the task */
          task.resume()
     }
     
     
     func escapedParameters(parameters: [String : AnyObject]) -> String {
          
          var urlVars = [String]()
          
          for (key, value) in parameters {
               
               /* Make sure that it is a string value */
               let stringValue = "\(value)"
               
               /* Escape it */
               let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
               
               /* Append it */
               urlVars += [key + "=" + "\(escapedValue!)"]
               
          }
          
          return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
     }
}

