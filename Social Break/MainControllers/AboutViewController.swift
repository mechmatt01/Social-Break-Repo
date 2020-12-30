//
//  AboutViewController.swift
//  Social Break
//
//  Created by Matthew Mech on 12/14/20.
//

import UIKit
import CoreData

class AboutViewController: BasePageController {
    
    @IBOutlet weak var contactUs: UIButton!
    @IBOutlet weak var icons8LicenseInfo: UIButton!
    @IBOutlet weak var resetAppButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    
    override var bgView: UIView {
        return self.backgroundView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resetAppButton?.addTarget(self, action: #selector(resetApp), for: .touchUpInside)
        self.icons8LicenseInfo?.addTarget(self, action: #selector(icons8License), for: .touchUpInside)
    }
    
    @objc func icons8License() {
        self.performSegue(withIdentifier: "showIcons8Info", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showIcons8Info",
           let nextScene = segue.destination as? LicenseViewController {
            nextScene.selectedIndex = "icons8"
        }
    }
    
    @objc func resetApp() {
        let alertController = UIAlertController(title: "Reset App?", message: "Are you sure you would like to reset the app? This will reset everything including your stats.", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Yes", style: .destructive) { (_) -> Void in
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.removeAllPendingNotificationRequests()
            notificationCenter.removeAllDeliveredNotifications()
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Sessions")
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(fetchRequest)
                for object in results {
                    guard let objectData = object as? NSManagedObject else {continue}
                    context.delete(objectData)
                }
            } catch let error {
                print("Detele all data in Sessions error :", error)
            }
            
            UserDefaults.standard.set(false, forKey: "hasCompletedIntro")
            
            let exitAppAlert = UIAlertController(title: "Restart is needed", message: "For this change to take full affect we need to restart the app.", preferredStyle: .alert)
            let resetApp = UIAlertAction(title: "Close App", style: .destructive) {
                (alert) -> Void in
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    exit(EXIT_SUCCESS)
                })
            }
            exitAppAlert.addAction(resetApp)
            self.present(exitAppAlert, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: false, completion: nil)
    }
}
