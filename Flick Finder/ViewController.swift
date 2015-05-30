//
//  ViewController.swift
//  Flick Finder
//
//  Created by Christopher Burgess on 5/25/15.
//  Copyright (c) 2015 Christopher Burgess. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

     @IBOutlet weak var flickImage: UIImageView!
     @IBOutlet weak var searchTextField: UITextField!
     @IBOutlet weak var latTextField: UITextField!
     @IBOutlet weak var longTextField: UITextField!
     @IBOutlet weak var imageTitle: UILabel!
     @IBOutlet weak var placeholderLabel: UILabel!
     @IBOutlet weak var searchForImageLabel: UILabel!
     
     let BASE_URL = "https://api.flickr.com/services/rest/"
     
     var tapRecognizer: UITapGestureRecognizer? = nil
     let BOUNDING_BOX_HALF_WIDTH = 1.0
     let BOUNDING_BOX_HALF_HEIGHT = 1.0
     let LAT_MIN = -90.0
     let LAT_MAX = 90.0
     let LON_MIN = -180.0
     let LON_MAX = 180.0
     
     override func viewDidLoad() {
          super.viewDidLoad()
          // Do any additional setup after loading the view, typically from a nib.
          
          searchTextField.delegate = self
          latTextField.delegate = self
          longTextField.delegate = self
          
          tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
          tapRecognizer?.numberOfTapsRequired = 1
     }

     override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
          // Dispose of any resources that can be recreated.
     }
     
     
     override func viewWillAppear(animated: Bool) {
          super.viewWillAppear(animated)
          
          println("Add the tapRecognizer and subscribe to keyboard notifications in viewWillAppear")
          
          /* Add tap recognizer to dismiss keyboard */
          self.addKeyboardDismissRecognizer()
          
          self.subscribeToKeyboardNotifications()
     }
     
     override func viewWillDisappear(animated: Bool) {
          super.viewWillDisappear(animated)
          
          println("Remove the tapRecognizer and unsubscribe from keyboard notifications in viewWillDisappear")
          
          /* Remove tap recognizer */
          self.removeKeyboardDismissRecognizer()
          
          self.unsubscribeToKeyboardNotifications()
     }
     
     
     
     
     /* ============================================================
     * Functional stubs for handling UI problems
     * ============================================================ */
     
     /* 1 - Dismissing the keyboard */
     func addKeyboardDismissRecognizer() {
          println("Add the recognizer to dismiss the keyboard")
          self.view.addGestureRecognizer(tapRecognizer!)
     }
     
     func removeKeyboardDismissRecognizer() {
          println("Remove the recognizer to dismiss the keyboard")
          self.view.removeGestureRecognizer(tapRecognizer!)
     }
     
     func handleSingleTap(recognizer: UITapGestureRecognizer) {
          println("End editing here")
          self.view.endEditing(true)
     }
     
     /* 2 - Shifting the keyboard so it does not hide controls */
     func subscribeToKeyboardNotifications() {
          println("Subscribe to the KeyboardWillShow and KeyboardWillHide notifications")
          NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
          NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
     }
     
     func unsubscribeToKeyboardNotifications() {
          println("Unsubscribe to the KeyboardWillShow and KeyboardWillHide notifications")
          NSNotificationCenter.defaultCenter().removeObserver(self, name:
               UIKeyboardWillShowNotification, object: nil)
          NSNotificationCenter.defaultCenter().removeObserver(self, name:
               UIKeyboardWillHideNotification, object: nil)
     }
     
     func keyboardWillShow(notification: NSNotification) {
          println("Shift the view's frame up so that controls are shown")
          if searchTextField.isFirstResponder() || longTextField.isFirstResponder() || latTextField.isFirstResponder() {
               self.view.frame.origin.y -= getKeyboardHeight(notification)
          }
     }
     
     func keyboardWillHide(notification: NSNotification) {
          println("Shift the view's frame down so that the view is back to its original placement")
          if searchTextField.isFirstResponder() || longTextField.isFirstResponder() || latTextField.isFirstResponder() {
               self.view.frame.origin.y = 0
          }
     }
     
     func getKeyboardHeight(notification: NSNotification) -> CGFloat {
          println("Get and return the keyboard's height from the notification")
          let userInfo = notification.userInfo
          let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
          return keyboardSize.CGRectValue().height
     }
     
     // Dismisses keyboard when return is pressed
     func textFieldShouldReturn(textField: UITextField) -> Bool {
          searchTextField.resignFirstResponder()
          longTextField.resignFirstResponder()
          latTextField.resignFirstResponder()
          return true
     }
     
     
     
     
     
     
     
     @IBAction func searchTextButtonTouchUp(sender: AnyObject) {
          
          /* Added from student request -- hides keyboard after searching */
          self.dismissAnyVisibleKeyboards()
          
          
          if (searchTextField.text == "") {
               placeholderLabel.text = "Please enter a search value below."
          }
          else {
               placeholderLabel.alpha = 0
          
               let keyValuePairs = [
                    "method": "flickr.photos.search",
                    "api_key": "f23a3195f2fb63a93781aeb1421f26b4",
                    "text": searchTextField.text,
                    "safe_search": "1",
                    "extras": "url_m",
                    "format": "json",
                    "nojsoncallback": "1"
               ]
          
               getImageFromFlickrBySearch(keyValuePairs)
          }
     }
     
     @IBAction func searchLatLongButtonTouchUp(sender: AnyObject) {
          /* Added from student request -- hides keyboard after searching */
          self.dismissAnyVisibleKeyboards()
          
          
          if (latTextField.text == "" || longTextField.text == "") {
               placeholderLabel.text = "Please enter lat/long values below."
          }
          else {
               placeholderLabel.alpha = 0
               
               let keyValuePairs = [
                    "method": "flickr.photos.search",
                    "api_key": "f23a3195f2fb63a93781aeb1421f26b4",
                    "bbox": createBoundingBoxString(),
                    "safe_search": "1",
                    "extras": "url_m",
                    "format": "json",
                    "nojsoncallback": "1"
               ]
               
               getImageFromFlickrBySearch(keyValuePairs)
          }

     }
     
     func createBoundingBoxString() -> String {
          
          let latitude = (self.latTextField.text as NSString).doubleValue
          let longitude = (self.longTextField.text as NSString).doubleValue
          
          /* Fix added to ensure box is bounded by minimum and maximums */
          let bottom_left_lon = max(longitude - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
          let bottom_left_lat = max(latitude - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
          let top_right_lon = min(longitude + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
          let top_right_lat = min(latitude + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
          
          return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
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
                    
                    // store the parsed photos into a dictionary
                    if let photosDictionary = parsedResult.valueForKey("photos") as? NSDictionary {
                         
                         if let photoArray = photosDictionary.valueForKey("photo") as? [[String: AnyObject]] {
                              
                              // grab a random image index
                              let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
                              
                              let photoDictionary = photoArray[randomPhotoIndex] as [String: AnyObject]
                              
                              // get the url and title from dictionary
                                   
                              let photoTitle = photoDictionary["title"] as? String
                              let imageURLstring = photoDictionary["url_m"] as? String
                              let imageURL = NSURL(string: imageURLstring!)
                              
                              // if image exists, set the image and title
                              
                              
                              if let imageData = NSData(contentsOfURL: imageURL!) {
                                   dispatch_async(dispatch_get_main_queue(), {
                                        self.flickImage.image = UIImage(data: imageData)
                                        self.imageTitle.text = photoTitle
                                   })
                              } else {
                                   println("Image does not exist at \(imageURL)")
                              }
                              
                              
                              
                         } else {
                              println("Cannot find key 'photo' in \(photosDictionary)")
                         }
                         
                         
                         
                         
                         
                    } else {
                         println("Can't find key 'photos' in \(parsedResult)")
                    }
                    

                    
   
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
     
     /* This extension was added as a fix based on student comments */
     extension ViewController {
          func dismissAnyVisibleKeyboards() {
               if searchTextField.isFirstResponder() || latTextField.isFirstResponder() || longTextField.isFirstResponder() {
                    self.view.endEditing(true)
               }
          }
     }


