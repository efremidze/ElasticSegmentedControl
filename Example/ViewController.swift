//
//  ViewController.swift
//  Example
//
//  Created by Lasha Efremidze on 6/4/16.
//  Copyright © 2016 Lasha Efremidze. All rights reserved.
//

import UIKit
import ElasticSegmentedControl

class ViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: ElasticSegmentedControl! {
        didSet {
            segmentedControl.backgroundColor = UIColor(red: 77/255, green: 94/255, blue: 107/255, alpha: 1)
            segmentedControl.titles = ["Line", "Lyft", "Plus"]
            segmentedControl.titleColor = .whiteColor()
            segmentedControl.selectedTitleColor = .whiteColor()
            segmentedControl.font = UIFont(name: "HelveticaNeue-Medium", size: 13.0)
            segmentedControl.layer.borderColor = UIColor(red: 77/255, green: 94/255, blue: 107/255, alpha: 1).CGColor
            segmentedControl.thumbColor = UIColor(red: 234/255, green: 11/255, blue: 140/255, alpha: 1)
            segmentedControl.thumbInset = 2.0
//            segmentControl.setSelectedIndex(1, animated: true)
        }
    }
    
}
