//
//  MainViewController.swift
//  Fryes
//
//  Created by Jarvis Wu on 2018-11-15.
//  Copyright © 2018 Jarvis Wu. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var viewStatisticsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationButton.layer.cornerRadius = 10
        viewStatisticsButton.layer.cornerRadius = 10
    }

}
