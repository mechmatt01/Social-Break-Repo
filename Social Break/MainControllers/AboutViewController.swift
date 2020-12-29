//
//  AboutViewController.swift
//  Social Break
//
//  Created by Matthew Mech on 12/14/20.
//

import UIKit

class AboutViewController: BasePageController {
    
    @IBOutlet weak var resetAppButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    
    override var bgView: UIView {
        return self.backgroundView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resetAppButton?.addTarget(self, action: #selector(resetApp), for: .touchUpInside)
    }
    
    @objc func resetApp() {
        let alertController = UIAlertController(title: "Are You Sure?", message: "This will reset the app.", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Yes", style: .destructive) { (_) -> Void in
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.removeAllPendingNotificationRequests()
            notificationCenter.removeAllDeliveredNotifications()
            UserDefaults.standard.set(false, forKey: "hasCompletedIntro")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: false, completion: nil)
    }
}
