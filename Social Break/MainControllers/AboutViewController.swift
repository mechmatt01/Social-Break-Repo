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
    @IBOutlet weak var unsplashLicenseInfo: UIButton!
    @IBOutlet weak var firebaseLicenseInfo: UIButton!
    @IBOutlet weak var resetAppButton: UIButton!
    @IBOutlet weak var versionInfo: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    
    override var bgView: UIView {
        return self.backgroundView
    }
    
    var appVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resetAppButton?.addTarget(self, action: #selector(resetApp), for: .touchUpInside)
        self.icons8LicenseInfo?.addTarget(self, action: #selector(showIcons8License), for: .touchUpInside)
        self.unsplashLicenseInfo?.addTarget(self, action: #selector(showUnsplashLicenseInfo), for: .touchUpInside)
        self.firebaseLicenseInfo?.addTarget(self, action: #selector(showFirebaseLicense), for: .touchUpInside)
        self.contactUs?.addTarget(self, action: #selector(contactUsAction), for: .touchUpInside)
        
        self.versionInfo.text =
            """
            Social Break © 2021
            Version \(appVersion ?? "--") (\(buildVersionNumber ?? "--"))
            
            Made with ❤️ and Pride in Philadelphia
            """
    }
    
    @objc func contactUsAction() {
        let emailURL = NSURL(string: "mailto:SocialBreakAppHelp@gmail.com?subject=Support&")
        UIApplication.shared.open(emailURL! as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    
    @objc func showIcons8License() {
        self.performSegue(withIdentifier: "showIcons8LicenseInfo", sender: self)
    }
    
    @objc func showFirebaseLicense() {
        self.performSegue(withIdentifier: "showFirebaseLicenseInfo", sender: self)
    }
    
    @objc func showUnsplashLicenseInfo() {
        self.performSegue(withIdentifier: "showUnsplashLicenseInfo", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showIcons8LicenseInfo",
           let nextScene = segue.destination as? LicenseViewController {
            nextScene.selectedIndex = "icons8"
        } else if segue.identifier == "showUnsplashLicenseInfo",
            let nextScene = segue.destination as? LicenseViewController {
             nextScene.selectedIndex = "unsplash"
        } else if segue.identifier == "showFirebaseLicenseInfo",
            let nextScene = segue.destination as? LicenseViewController {
            nextScene.selectedIndex = "firebase"
        }
    }
    
    func getBackgroundImageSound(backgroundImage: String) -> String {
        if backgroundImage == "BackgroundImage1" || backgroundImage == "BackgroundImage10" || backgroundImage == "BackgroundImage19" {
            // Forest Sounds
            return "ForestSound.wav"
        } else if backgroundImage == "BackgroundImage12" || backgroundImage == "BackgroundImage15" || backgroundImage == "BackgroundImage16" {
            // Driving Sounds
            return "DrivingSound.wav"
        } else if backgroundImage == "BackgroundImage5" || backgroundImage == "BackgroundImage13" || backgroundImage == "BackgroundImage14" {
            // City Sounds
            return "CitySound.wav"
        } else if backgroundImage == "BackgroundImage4" || backgroundImage == "BackgroundImage8" {
            // Water Flowing Sounds
            return "WaterFlowingSound.wav"
        } else if backgroundImage == "BackgroundImage2" || backgroundImage == "BackgroundImage20" {
            // Beach Sounds
            return "BeachSound.wav"
        } else if backgroundImage == "BackgroundImage3" || backgroundImage == "BackgroundImage6" || backgroundImage == "BackgroundImage7" || backgroundImage == "BackgroundImage9" || backgroundImage == "BackgroundImage17" {
            // Mountain Nature Sounds
            return "MountainNatureSound.wav"
        } else if backgroundImage == "BackgroundImage18" {
            // Airplane Sounds
            return "AirplaneSound.wav"
        } else if backgroundImage == "BackgroundImage21" {
            // Camp Fire Sounds
            return "CampFireSound.wav"
        }
        return ""
    }
    
    @objc func resetApp() {
        let alertController = UIAlertController(title: "Reset App?", message: "Are you sure you would like to reset the app? This will reset everything including your stats.", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Yes", style: .destructive) { (_) -> Void in
            
            DispatchQueue.main.async {
                let backgroundImage = UserDefaults.standard.string(forKey: "backgroundImage") ?? "BackgroundImage1"
                
                let previousSoundName = self.getBackgroundImageSound(backgroundImage: backgroundImage)
                
                let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let previousDestinationUrl = documentsUrl.appendingPathComponent("\(previousSoundName)")
            
                try? FileManager.default.removeItem(at: previousDestinationUrl)
                
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
                    try context.save()
                } catch let error {
                    print("Detele all data in Sessions error: ", error)
                }
                
                UserDefaults.standard.set(false, forKey: "hasCompletedIntro")
                
                let exitAppAlert = UIAlertController(title: "Restart is needed", message: "For this change to take full affect we need to close the app.", preferredStyle: .alert)
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
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: false, completion: nil)
    }
}

fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
