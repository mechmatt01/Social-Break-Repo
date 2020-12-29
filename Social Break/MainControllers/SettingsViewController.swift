//
//  SettingsViewController.swift
//  Social Break
//
//  Created by Matthew Mech on 12/14/20.
//

import UIKit

class backgroundImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var selectedIcon: UIImageView!
    @IBOutlet weak var imageOverlay: UIView!
    @IBOutlet weak var imageView: UIImageView!
}

class SettingsViewController: BasePageController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var notifications: UISwitch!
    @IBOutlet weak var daysSelector: UIStackView!
    @IBOutlet weak var monday: UIButton!
    @IBOutlet weak var tuesday: UIButton!
    @IBOutlet weak var wednesday: UIButton!
    @IBOutlet weak var thursday: UIButton!
    @IBOutlet weak var friday: UIButton!
    @IBOutlet weak var saturday: UIButton!
    @IBOutlet weak var sunday: UIButton!
    @IBOutlet weak var timeSelector: UIDatePicker!
    @IBOutlet weak var UICollectionView: UICollectionView!
    
    let reuseIdentifier = "imageCell"
    
    var images = [UIImage]()
    var imageIndex = [Int]()
    let screenType = "\(UIDevice.current.screenType)"
    
    override var bgView: UIView {
        return self.backgroundView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                print("Notifications Pending: ", request.identifier)
                print("Notifications Pending: ", request.content.body)
            }
        })
        */
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if self.screenType == "iPhones_SE" || self.screenType == "iPhones_6_6s_7_8_SE2" {
            self.scrollView.isScrollEnabled = true
        } else {
            self.scrollView.isScrollEnabled = false
        }
        
        let daysArray = UserDefaults.standard.array(forKey: "daysForReminders") as? [Int] ?? [Int]()
        if daysArray.count > 0 {
            for day in daysArray {
                if day == 1 {
                    self.monday?.backgroundColor = .blue
                } else if day == 2 {
                    self.tuesday?.backgroundColor = .blue
                } else if day == 3 {
                    self.wednesday?.backgroundColor = .blue
                } else if day == 4 {
                    self.thursday?.backgroundColor = .blue
                } else if day == 5 {
                    self.friday?.backgroundColor = .blue
                } else if day == 6 {
                    self.saturday?.backgroundColor = .blue
                } else if day == 7 {
                    self.sunday?.backgroundColor = .blue
                }
            }
        }
        
        self.monday?.layer.cornerRadius = 20
        self.tuesday?.layer.cornerRadius = 20
        self.wednesday?.layer.cornerRadius = 20
        self.thursday?.layer.cornerRadius = 20
        self.friday?.layer.cornerRadius = 20
        self.saturday?.layer.cornerRadius = 20
        self.sunday?.layer.cornerRadius = 20
        self.monday?.layer.masksToBounds = true
        self.tuesday?.layer.masksToBounds = true
        self.wednesday?.layer.masksToBounds = true
        self.thursday?.layer.masksToBounds = true
        self.friday?.layer.masksToBounds = true
        self.saturday?.layer.masksToBounds = true
        self.sunday?.layer.masksToBounds = true
        self.monday?.tag = 1
        self.tuesday?.tag = 2
        self.wednesday?.tag = 3
        self.thursday?.tag = 4
        self.friday?.tag = 5
        self.saturday?.tag = 6
        self.sunday?.tag = 0
        self.monday?.addTarget(self, action: #selector(daySelected(sender:)), for: .touchUpInside)
        self.tuesday?.addTarget(self, action: #selector(daySelected(sender:)), for: .touchUpInside)
        self.wednesday?.addTarget(self, action: #selector(daySelected(sender:)), for: .touchUpInside)
        self.thursday?.addTarget(self, action: #selector(daySelected(sender:)), for: .touchUpInside)
        self.friday?.addTarget(self, action: #selector(daySelected(sender:)), for: .touchUpInside)
        self.saturday?.addTarget(self, action: #selector(daySelected(sender:)), for: .touchUpInside)
        self.sunday?.addTarget(self, action: #selector(daySelected(sender:)), for: .touchUpInside)
        
        self.userName?.delegate = self
        self.userName?.text = UserDefaults.standard.string(forKey: "userDisplayName")
        
        self.timeSelector?.overrideUserInterfaceStyle = .dark
        self.daysSelector?.overrideUserInterfaceStyle = .dark
        
        if UserDefaults.standard.object(forKey: "timeForReminders") != nil {
            let dateSet = UserDefaults.standard.object(forKey: "timeForReminders") as? Date ?? Date()
            self.timeSelector?.setDate(dateSet, animated: true)
        }
        
        self.timeSelector?.addTarget(self, action: #selector(setNewTime), for: .valueChanged)
        
        if #available(iOS 14.0, *) {
            self.timeSelector?.preferredDatePickerStyle = .inline
        }
        
        self.notifications?.addTarget(self, action: #selector(changeNotificationPrefrences), for: .touchUpInside)
        
        
        if UserDefaults.standard.bool(forKey: "notificationsEnabled") == true {
            self.notifications?.isOn = true
        } else {
            let current = UNUserNotificationCenter.current()
            current.getNotificationSettings { (settings) in
                if settings.authorizationStatus == .authorized {
                    // Already authorized
                    self.notifications?.isOn = true
                    if UserDefaults.standard.bool(forKey: "notificationsEnabled") == false {
                        UserDefaults.standard.set(true, forKey: "notificationsEnabled")
                    }
                } else if settings.authorizationStatus == .denied || settings.authorizationStatus == .notDetermined {
                    // Either denied or notDetermined
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .provisional]) {
                        (granted, error) in
                        UNUserNotificationCenter.current().delegate = self
                        let alertController = UIAlertController(title: "Notifications Disabled", message: "Please go to the settings to enable notifications. Then restart the app.", preferredStyle: .alert)
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
                            }
                            self.notifications?.isOn = true
                        } else {
                            UserDefaults.standard.set(false, forKey: "notificationsEnabled")
                            self.notifications?.isOn = false
                        }
                    })
                }
            }
        }
        
        let image1  = UIImage(named: "BackgroundImage1")
        let image2  = UIImage(named: "BackgroundImage2")
        let image3  = UIImage(named: "BackgroundImage3")
        let image4  = UIImage(named: "BackgroundImage4")
        let image5  = UIImage(named: "BackgroundImage5")
        let image6  = UIImage(named: "BackgroundImage6")
        let image7  = UIImage(named: "BackgroundImage7")
        let image8  = UIImage(named: "BackgroundImage8")
        let image9  = UIImage(named: "BackgroundImage9")
        let image10 = UIImage(named: "BackgroundImage10")
        
        let currentSetImage = UIImage(named: "\(UserDefaults.standard.string(forKey: "backgroundImage") ?? "BackgroundImage1")")
        
        images = [image1, image2, image3, image4, image5, image6, image7, image8, image9, image10] as! [UIImage]
        imageIndex = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        
        for (index, image) in images.enumerated() {
            if image == currentSetImage {
                images.remove(at: index)
                images.insert(image, at: 0)
                
                imageIndex.remove(at: index)
                imageIndex.insert(index, at: 0)
            }
        }
        
        UICollectionView?.backgroundColor = .clear
        //UICollectionView?.clipsToBounds = true
        UICollectionView?.allowsMultipleSelection = false
        UICollectionView?.contentInsetAdjustmentBehavior = .always
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
         self.view.frame.origin.y = -100 // Move view 100 points upward
    }

    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0 // Move view to original position
    }
    
    @objc func setNewTime() {
        var daysArray = UserDefaults.standard.array(forKey: "daysForReminders") as? [Int] ?? [Int]()
        var daysUUIDArray = UserDefaults.standard.array(forKey: "daysUUIDArray") as? [String] ?? [String]()
        let newUUIDString = UUID().uuidString
        
        for (index, UUID) in daysUUIDArray.enumerated() {
            if UUID != "" {
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [UUID])
                daysUUIDArray.remove(at: index)
                daysUUIDArray.insert("", at: index)
                UserDefaults.standard.set(daysUUIDArray, forKey: "daysUUIDArray")
            }
        }
        
        for day in daysArray {
            daysArray.append(day)
            daysUUIDArray.remove(at: day)
            daysUUIDArray.insert(newUUIDString, at: day)
            if day == 0 {
                self.sunday?.backgroundColor = .blue
            } else if day == 1 {
                self.monday?.backgroundColor = .blue
            } else if day == 2 {
                self.tuesday?.backgroundColor = .blue
            } else if day == 3 {
                self.wednesday?.backgroundColor = .blue
            } else if day == 4 {
                self.thursday?.backgroundColor = .blue
            } else if day == 5 {
                self.friday?.backgroundColor = .blue
            } else if day == 6 {
                self.saturday?.backgroundColor = .blue
            }
            UserDefaults.standard.set(daysArray, forKey: "daysForReminders")
            UserDefaults.standard.set(daysUUIDArray, forKey: "daysUUIDArray")
            
            let content = UNMutableNotificationContent()
            content.title = "Time for a Break"
            content.body = "Let's get Productive"
            
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            
            let date = self.timeSelector.date
            let hourCurrent = Calendar.current.component(.hour, from: date)
            let minuteCurrent = Calendar.current.component(.minute, from: date)
            
            dateComponents.weekday = day + 1 // Day of the week as a number (1 = Sunday)
            dateComponents.hour = hourCurrent // hours
            dateComponents.minute = minuteCurrent // minutes
            
            print("weekdayCurrent: ", day + 1)
            print("hourCurrent: ", hourCurrent)
            print("minuteCurrent: ", minuteCurrent)
            
            // Create the trigger as a repeating event.
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            var uuidString = ""
            if daysUUIDArray[day] != "" {
                uuidString = daysUUIDArray[day]
            } else {
                uuidString = newUUIDString
                daysUUIDArray.remove(at: day)
                daysUUIDArray.insert(newUUIDString, at: day)
                UserDefaults.standard.set(daysUUIDArray, forKey: "daysUUIDArray")
            }
            
            print("Notification Set for \(day + 1) at \(date)")
            
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            
            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
                if error != nil {
                    print("Error adding notification: ", error?.localizedDescription ?? "nil")
                }
            }
        }
    }
    
    @objc func daySelected(sender: UIButton) {
        var daysArray = UserDefaults.standard.array(forKey: "daysForReminders") as? [Int] ?? [Int]()
        var daysUUIDArray = UserDefaults.standard.array(forKey: "daysUUIDArray") as? [String] ?? [String]()
        let newUUIDString = UUID().uuidString
        
        if daysArray.contains(sender.tag) {
            for (index, number) in daysArray.enumerated() {
                if number == sender.tag {
                    let UUIDToRemove = daysUUIDArray[index]
                    let notificationCenter = UNUserNotificationCenter.current()
                    notificationCenter.removePendingNotificationRequests(withIdentifiers: [UUIDToRemove])
                    daysUUIDArray.remove(at: index)
                    daysUUIDArray.insert("", at: index)
                    daysArray.remove(at: index)
                    if sender.tag == 0 {
                        self.sunday?.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500)
                    } else if sender.tag == 1 {
                        self.monday?.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500)
                    } else if sender.tag == 2 {
                        self.tuesday?.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500)
                    } else if sender.tag == 3 {
                        self.wednesday?.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500)
                    } else if sender.tag == 4 {
                        self.thursday?.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500)
                    } else if sender.tag == 5 {
                        self.friday?.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500)
                    } else if sender.tag == 6 {
                        self.saturday?.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500)
                    }
                    UserDefaults.standard.set(daysArray, forKey: "daysForReminders")
                    UserDefaults.standard.set(daysUUIDArray, forKey: "daysUUIDArray")
                }
            }
        } else {
            daysArray.append(sender.tag)
            daysUUIDArray.remove(at: sender.tag)
            daysUUIDArray.insert(newUUIDString, at: sender.tag)
            if sender.tag == 0 {
                self.sunday?.backgroundColor = .blue
            } else if sender.tag == 1 {
                self.monday?.backgroundColor = .blue
            } else if sender.tag == 2 {
                self.tuesday?.backgroundColor = .blue
            } else if sender.tag == 3 {
                self.wednesday?.backgroundColor = .blue
            } else if sender.tag == 4 {
                self.thursday?.backgroundColor = .blue
            } else if sender.tag == 5 {
                self.friday?.backgroundColor = .blue
            } else if sender.tag == 6 {
                self.saturday?.backgroundColor = .blue
            }
            UserDefaults.standard.set(daysArray, forKey: "daysForReminders")
            UserDefaults.standard.set(daysUUIDArray, forKey: "daysUUIDArray")
            
            let content = UNMutableNotificationContent()
            content.title = "Time for a Break"
            content.body = "Let's get Productive"
            
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            
            let date = self.timeSelector.date
            let hourCurrent = Calendar.current.component(.hour, from: date)
            let minuteCurrent = Calendar.current.component(.minute, from: date)
            
            dateComponents.weekday = sender.tag + 1 // Day of the week as a number (1 = Sunday)
            dateComponents.hour = hourCurrent // hours
            dateComponents.minute = minuteCurrent // minutes
            
            print("weekdayCurrent: ", sender.tag)
            print("hourCurrent: ", hourCurrent)
            print("minuteCurrent: ", minuteCurrent)
            
            // Create the trigger as a repeating event.
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            var uuidString = ""
            if daysUUIDArray[sender.tag] != "" {
                uuidString = daysUUIDArray[sender.tag]
            } else {
                uuidString = newUUIDString
                daysUUIDArray.remove(at: sender.tag)
                daysUUIDArray.insert(newUUIDString, at: sender.tag)
                UserDefaults.standard.set(daysUUIDArray, forKey: "daysUUIDArray")
            }
            
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            
            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
                if error != nil {
                    print("Error adding notification: ", error?.localizedDescription ?? "nil")
                }
            }
        }
    }
    
    
    @objc func changeNotificationPrefrences() {
        if self.notifications?.isOn == true {
            UserDefaults.standard.set(false, forKey: "notificationsEnabled")
            self.notifications?.isOn = false
        } else {
            let current = UNUserNotificationCenter.current()
            current.getNotificationSettings { (settings) in
                if settings.authorizationStatus == .denied || settings.authorizationStatus == .notDetermined {
                    // Either denied or notDetermined
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .provisional]) {
                        (granted, error) in
                        UNUserNotificationCenter.current().delegate = self
                        let alertController = UIAlertController(title: "Notifications Disabled", message: "Please go to the settings to enable notifications. Then restart the app.", preferredStyle: .alert)
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
                            }
                            self.notifications?.isOn = true
                        } else {
                            UserDefaults.standard.set(false, forKey: "notificationsEnabled")
                            self.notifications?.isOn = false
                        }
                    })
                }
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.userName.hasText == true && self.userName.text?.isEmpty == false {
            UserDefaults.standard.set("\(self.userName.text ?? "")", forKey: "userDisplayName")
        } else {
            self.userName?.text = UserDefaults.standard.string(forKey: "userDisplayName")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.userName.resignFirstResponder()
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        self.scrollView?.touchesShouldCancel(in: collectionView)
        self.scrollView?.canCancelContentTouches = true
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(reuseIdentifier)", for: indexPath) as! backgroundImageCollectionViewCell
        
        if indexPath.row == 0 {
            cell.selectedIcon.isHidden = false
        } else {
            cell.selectedIcon.isHidden = true
        }
        
        DispatchQueue.main.async {
            cell.imageView?.image = self.images[indexPath.item]
        }
        cell.imageView.contentMode = .scaleAspectFill
        
        cell.tag = indexPath.row
        cell.layer.cornerRadius = 15
        cell.layer.masksToBounds = true
        
        collectionView.delaysContentTouches = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        //print("self.images[indexPath.item] shouldSelect: ", self.images[indexPath.item])
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("self.images[indexPath.item] didSelect: ", self.images[indexPath.item])
        print("self.images[indexPath.row] didSelect: \(self.imageIndex[indexPath.row])")
        
        if UIImage(named: "BackgroundImage\(imageIndex[indexPath.row])") != nil {
            UserDefaults.standard.set("BackgroundImage\(imageIndex[indexPath.row])", forKey: "backgroundImage")
            
            for (index, image) in images.enumerated() {
                if image == UIImage(named: "BackgroundImage\(imageIndex[indexPath.row])") {
                    images.remove(at: index)
                    images.insert(image, at: 0)
                    imageIndex.remove(at: index)
                    imageIndex.insert(indexPath.row, at: 0)
                }
            }
        } else {
            UserDefaults.standard.set("BackgroundImage1", forKey: "backgroundImage")
            
            for (index, image) in images.enumerated() {
                if image == UIImage(named: "BackgroundImage\(1)") {
                    images.remove(at: index)
                    images.insert(image, at: 0)
                    imageIndex.remove(at: index)
                    imageIndex.insert(1, at: 0)
                }
            }
        }
        
        /*
         let indexPathPrev = IndexPath(row: selectedImageIndex, section: 0)
         let cellPrevSelected = collectionView.dequeueReusableCell(withReuseIdentifier: "\(reuseIdentifier)", for: indexPathPrev) as! backgroundImageCollectionViewCell
         cellPrevSelected.selectedIcon.isHidden = true
         
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(reuseIdentifier)", for: indexPath) as! backgroundImageCollectionViewCell
         cell.selectedIcon.isHidden = false
         */
        
        self.UICollectionView.performBatchUpdates({
            
            let indexSet = IndexSet(integersIn: 0...0)
            self.UICollectionView.reloadSections(indexSet)
        }, completion: nil)
        
        //self.UICollectionView.reloadData()
        let pageController = MainPageViewController()
        pageController.reloadPageController()
    }
}
