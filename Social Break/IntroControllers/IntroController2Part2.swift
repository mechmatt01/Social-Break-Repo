//
//  IntroController2Part2.swift
//  Social Break
//
//  Created by Matthew Mech on 12/14/20.
//

import UIKit

class IntroController2Part2: UIViewController {
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var daysSelector: UIStackView!
    @IBOutlet weak var monday: UIButton!
    @IBOutlet weak var tuesday: UIButton!
    @IBOutlet weak var wednesday: UIButton!
    @IBOutlet weak var thursday: UIButton!
    @IBOutlet weak var friday: UIButton!
    @IBOutlet weak var saturday: UIButton!
    @IBOutlet weak var sunday: UIButton!
    @IBOutlet weak var timeSelector: UIDatePicker!
    
    let buttonSelectedColor = UIColor(red: 0.227, green: 0.722, blue: 0.922, alpha: 1.000)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.continueButton?.addTarget(self, action: #selector(continueToNextStep), for: .touchUpInside)
        self.continueButton?.layer.cornerRadius = 15.5
        self.continueButton?.layer.masksToBounds = true
        
        UserDefaults.standard.set(["", "", "", "", "", "", ""], forKey: "daysUUIDArray")
        UserDefaults.standard.set([], forKey: "daysForReminders")
        
        self.timeSelector?.overrideUserInterfaceStyle = .dark
        self.daysSelector?.overrideUserInterfaceStyle = .dark
        
        if #available(iOS 14.0, *) {
            self.timeSelector?.preferredDatePickerStyle = .inline
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
        
        self.sunday?.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500)
        self.monday?.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500)
        self.tuesday?.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500)
        self.wednesday?.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500)
        self.thursday?.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500)
        self.friday?.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500)
        self.saturday?.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500)
    }
    
    @objc func continueToNextStep() {
        let daysArray = UserDefaults.standard.array(forKey: "daysForReminders") as? [Int] ?? [Int]()
        var daysUUIDArray = UserDefaults.standard.array(forKey: "daysUUIDArray") as? [String] ?? [String]()
        let newUUIDString = UUID().uuidString
        
        for day in daysArray {
            let content = UNMutableNotificationContent()
            content.title = "Time to take a Social Break"
            
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            
            let date = self.timeSelector.date
            let hourCurrent = Calendar.current.component(.hour, from: date)
            let minuteCurrent = Calendar.current.component(.minute, from: date)
            
            dateComponents.weekday = day + 1 // Day of the week as a number (1 = Sunday)
            dateComponents.hour = hourCurrent // hours
            dateComponents.minute = minuteCurrent // minutes

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
            
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            
            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
                if error != nil {
                    print("Error adding notification: ", error?.localizedDescription ?? "nil")
                    let alertController = UIAlertController(title: "Error", message: "An error has ocurred when setting notification preferences. Please try again.", preferredStyle: .alert)
                    let continueAction = UIAlertAction(title: "Try Again", style: .default, handler: nil)
                    alertController.addAction(continueAction)
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                    notificationCenter.removeAllPendingNotificationRequests()
                    return
                }
            }
        }
        UserDefaults.standard.set(self.timeSelector.date, forKey: "timeForReminders")
        self.performSegue(withIdentifier: "goToStep3", sender: self)
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
                self.sunday?.backgroundColor = buttonSelectedColor
            } else if sender.tag == 1 {
                self.monday?.backgroundColor = buttonSelectedColor
            } else if sender.tag == 2 {
                self.tuesday?.backgroundColor = buttonSelectedColor
            } else if sender.tag == 3 {
                self.wednesday?.backgroundColor = buttonSelectedColor
            } else if sender.tag == 4 {
                self.thursday?.backgroundColor = buttonSelectedColor
            } else if sender.tag == 5 {
                self.friday?.backgroundColor = buttonSelectedColor
            } else if sender.tag == 6 {
                self.saturday?.backgroundColor = buttonSelectedColor
            }
            UserDefaults.standard.set(daysArray, forKey: "daysForReminders")
            UserDefaults.standard.set(daysUUIDArray, forKey: "daysUUIDArray")
        }
        
    }
}
