//
//  InfoViewController.swift
//  BTLETools
//
//  Created by Tijn Kooijmans on 09/11/2016.
//
//

import UIKit

class InfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func actionOpenWebsite(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "http://www.studiosophisti.nl")!)
    }
 
}
