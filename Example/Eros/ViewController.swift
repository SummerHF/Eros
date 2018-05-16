//
//  ViewController.swift
//  Eros
//
//  Created by SummerHF on 05/16/2018.
//  Copyright (c) 2018 SummerHF. All rights reserved.
//

import UIKit
import Eros

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let manager = NetworkReachablityManager() {
           print(manager.isReachable)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
