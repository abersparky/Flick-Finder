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
     
     
     @IBAction func searchTextButtonTouchUp(sender: AnyObject) {
          
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


}

