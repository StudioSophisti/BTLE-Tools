//
//  LogViewController.swift
//  BTLETools
//
//  Created by Tijn Kooijmans on 09/11/2016.
//
//

import UIKit

class LogViewController: UIViewController {

    @IBOutlet weak var txtView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Logger.shared.logChangedCallback = {
            self.txtView.text = Logger.shared.log
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.becomeFirstResponder()
    }
    
    @IBAction func actionClear(_ sender: Any) {
        Logger.shared.clear()
    }
    
    @IBAction func actionExport(_ sender: Any) {
        let objectsToShare = [Logger.shared.export(), "BLE Tools log export"] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
        }
        activityVC.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        self.present(activityVC, animated: true, completion: nil)
    }
    
}
