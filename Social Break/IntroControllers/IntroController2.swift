//
//  IntroController2.swift
//  Social Break
//
//  Created by Matthew Mech on 12/14/20.
//

import UIKit

class IntroController2: UIViewController, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var allowNotifications: UIButton!
    @IBOutlet weak var disableNotifications: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.allowNotifications?.addTarget(self, action: #selector(setUpNotificationReminders), for: .touchUpInside)
        self.allowNotifications?.layer.cornerRadius = 15.25
        self.allowNotifications?.layer.masksToBounds = true
        
        self.disableNotifications?.addTarget(self, action: #selector(continueWithoutNotificationReminders), for: .touchUpInside)
        self.disableNotifications?.layer.cornerRadius = 15.25
        self.disableNotifications?.layer.masksToBounds = true
        
        UNUserNotificationCenter.current().delegate = self
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                UserDefaults.standard.set(false, forKey: "notificationsEnabled")
            }
        }
    }
    
    @objc func setUpNotificationReminders() {
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                // Already authorized
                UserDefaults.standard.set(true, forKey: "notificationsEnabled")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    self.performSegue(withIdentifier: "goToStep2Part2", sender: self)
                }
            } else if settings.authorizationStatus == .denied {
                // Notifications denied
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .provisional]) {
                    (granted, error) in
                    UNUserNotificationCenter.current().delegate = self
                    let alertController = UIAlertController(title: "Notifications Disabled", message: "Please go to the settings to enable notifications", preferredStyle: .alert)
                    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            })
                        }
                    }
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    alertController.addAction(cancelAction)
                    alertController.addAction(settingsAction)
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            } else {
                // Notification permission has not been called yet
                let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound, .provisional]
                UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { (isSuccess, error) in
                    if let error = error {
                        print("Error: ", error.localizedDescription)
                    }
                    if isSuccess == true {
                        UserDefaults.standard.set(true, forKey: "notificationsEnabled")
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                            self.performSegue(withIdentifier: "goToStep2Part2", sender: self)
                        }
                    } else {
                        UserDefaults.standard.set(false, forKey: "notificationsEnabled")
                    }
                })
            }
        }
    }
    
    @objc func continueWithoutNotificationReminders() {
        UserDefaults.standard.set(false, forKey: "notificationsEnabled")
        UserDefaults.standard.set(["", "", "", "", "", "", ""], forKey: "daysUUIDArray")
        UserDefaults.standard.set([], forKey: "daysForReminders")
        self.performSegue(withIdentifier: "goToStep3", sender: self)
    }
}
