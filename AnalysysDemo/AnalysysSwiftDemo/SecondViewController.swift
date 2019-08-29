//
//  SecondViewController.swift
//  AnalysysSwiftDemo
//
//  Created by SoDo on 2018/12/24.
//  Copyright © 2018 analysys. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let properties = ["name": "iphone", "price": 9000] as [String: Any]
        AnalysysAgent.pageView("商品页", properties: properties)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
