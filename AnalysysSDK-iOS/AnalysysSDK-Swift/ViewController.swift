//
//  ViewController.swift
//  AnalysysSDK-Swift
//
//  Created by SoDo on 2019/3/1.
//  Copyright © 2019 shaochong du. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


    @IBAction func trackAction(_ sender: Any) {
        AnalysysAgent.track("buy")
        
        AnalysysAgent.track("favor", properties: ["music":"17 years old"])
    }
}

