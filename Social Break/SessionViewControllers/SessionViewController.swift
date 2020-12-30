//
//  SessionViewController.swift
//  Social Break
//
//  Created by Matthew Mech on 12/14/20.
//

import UIKit
import CoreData

class sessionViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var goal: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var timer: Timer?
    var timeTimer = Timer()
    
    var selectedTime: Double = 0.0
    var goalString: String = ""
    var sessionID: String = ""
    var randomString = ""
    
    let uuidString = UUID().uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.string(forKey: "backgroundImage") ?? "BackgroundImage1" == "BackgroundImage1" {
            self.backgroundImageView?.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.250)
        } else {
            self.backgroundImageView?.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500)
        }
        
        timeRemainingLabel.alpha = 0.0
        
        self.goal?.text = goalString
        
        self.selectedTime = self.selectedTime + 1.0
        
        self.startButton?.layer.cornerRadius = 19.5
        self.startButton?.layer.masksToBounds = true
        self.startButton?.addTarget(self, action: #selector(startTimer), for: .touchUpInside)
        
        self.currentTimeLabel.text = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
        self.timeTimer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector:#selector(self.timeUpdate), userInfo: nil, repeats: true)
        
        self.backgroundImage?.image = UIImage(named: "\(UserDefaults.standard.string(forKey: "backgroundImage") ?? "BackgroundImage1")")
        self.backgroundImage?.contentMode = .scaleAspectFill
        
        self.cancelButton?.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
    }
    
    @objc func startTimer() {
        UIView.animate(withDuration: 0.3, animations: {
            self.startButton.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.startButton.alpha = 0
            self.timeRemainingLabel.alpha = 1.0
        }) { (success: Bool) in
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let context = appDelegate.persistentContainer.viewContext
            
            let entity = NSEntityDescription.entity(forEntityName: "Sessions", in: context)
            let newSession = NSManagedObject(entity: entity!, insertInto: context)
            
            let sessionID = self.randomString.randomString(10)
            self.sessionID = sessionID
            
            let currentDate = Date()
            
            newSession.setValue(sessionID, forKey: "sessionID")
            newSession.setValue(true, forKey: "isActive")
            newSession.setValue(self.goalString, forKey: "sessionGoal")
            newSession.setValue(currentDate, forKey: "sessionDate")
            newSession.setValue(currentDate, forKey: "sessionStartTime")
            newSession.setValue(currentDate, forKey: "sessionEndTime")
            newSession.setValue(0.0, forKey: "sessionLength")
            
            do {
                try context.save()
            } catch let error as NSError {
                print("Error when trying to save new session: \(error), \(error.userInfo)")
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Break Ended"
            content.body = "Break has ended"
            
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            
            let weekdayCurrent = Calendar.current.component(.weekday, from: Date())
            let hourCurrent = Calendar.current.component(.hour, from: Date())
            
            let minutes1 = Int(self.selectedTime) % 3600
            let minutes2 = (minutes1 / 60)
            
            let minuteCurrent = Calendar.current.component(.minute, from: Date()) + minutes2
            
            dateComponents.weekday = weekdayCurrent // Day of the week as a number (1 = Sunday)
            dateComponents.hour = hourCurrent // hours
            dateComponents.minute = minuteCurrent // minutes
            
            print("weekdayCurrent: ", weekdayCurrent)
            print("hourCurrent: ", hourCurrent)
            print("minuteCurrent: ", minuteCurrent)
            
            // Create the trigger as a repeating event.
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: self.uuidString, content: content, trigger: trigger)
            
            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
                if error != nil {
                    print("Error: ", error?.localizedDescription ?? "nil")
                }
            }
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                
                self.selectedTime -= 1
                
                let selectedTimeInt = Int(self.selectedTime)
                /*
                let hours = String(selectedTimeInt / 3600)
                let minutes = String((selectedTimeInt % 3600) / 60)
                var seconds = String((selectedTimeInt % 3600) % 60)
                */
                
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.hour, .minute, .second]
                formatter.unitsStyle = .positional

                let formattedString = formatter.string(from: TimeInterval(selectedTimeInt))!
                self.timeRemainingLabel.text = formattedString

                /*
                if seconds == "0" || seconds == "1" || seconds == "2" || seconds == "3" || seconds == "4" || seconds == "5" || seconds == "6" || seconds == "7" || seconds == "8" || seconds == "9" {
                    seconds = "0" + seconds
                }
                
                if hours == "0" && minutes == "0" {
                    let timeString = seconds
                    self.timeRemainingLabel.text = timeString
                } else if hours == "0" {
                    let timeString = minutes + ":" + seconds
                    self.timeRemainingLabel.text = timeString
                } else {
                    let timeString = hours + ":" + minutes + ":" + seconds
                    self.timeRemainingLabel.text = timeString
                }
                */
                
                if self.selectedTime == 0 {
                    self.sessionEndUpdateDataFields()
                    timer.invalidate()
                    self.timeRemainingLabel.font = UIFont.SFProRoundedBoldFont(size: 30)
                    self.timeRemainingLabel.numberOfLines = 2
                    self.timeRemainingLabel.text = "Completed at \(DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short))"
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer?.tolerance = 0.3
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func timeUpdate() {
        currentTimeLabel.text = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
    }
    
    @objc func dismissView() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [self.uuidString])
        
        if timer?.isValid == true  {
            let alertController = UIAlertController(title: "Are You Sure?", message: "This will end your session.", preferredStyle: .alert)
            let continueAction = UIAlertAction(title: "End Session", style: .destructive) { (_) -> Void in
                self.sessionEndUpdateDataFields()
                UIView.animate(withDuration: 0.3, animations: {
                    self.backgroundImage.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                    
                    self.currentTimeLabel.alpha = 0
                    self.cancelButton.alpha = 0
                    self.timeRemainingLabel.alpha = 0
                    self.backgroundImage.alpha = 0
                    
                }) { (success: Bool) in
                    self.timer?.invalidate()
                    self.timeTimer.invalidate()
                    let mainVC = MainPageViewController()
                    mainVC.modalPresentationStyle = .fullScreen
                    if #available(iOS 13.0, *) {
                        mainVC.isModalInPresentation = true
                    }
                    self.present(mainVC, animated: false, completion: nil)
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(continueAction)
            self.present(alertController, animated: false, completion: nil)
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundImage.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                
                self.currentTimeLabel.alpha = 0
                self.cancelButton.alpha = 0
                self.timeRemainingLabel.alpha = 0
                self.backgroundImage.alpha = 0
                
            }) { (success: Bool) in
                self.timer?.invalidate()
                self.timeTimer.invalidate()
                let mainVC = MainPageViewController()
                mainVC.modalPresentationStyle = .fullScreen
                if #available(iOS 13.0, *) {
                    mainVC.isModalInPresentation = true
                }
                self.present(mainVC, animated: false, completion: nil)
            }
        }
    }
    
    func sessionEndUpdateDataFields() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Sessions")
        request.returnsObjectsAsFaults = false

         /*
         sessionID: String
         isActive: Bool
         sessionGoal: String
         sessionDate: Date
         sessionStartTime: Date
         sessionEndTime: Date
         sessionLength: Double
         */
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
                print(data.value(forKey: "sessionID") as! String? ?? "sessionID: nil")
                print(data.value(forKey: "isActive") as! Bool? ?? false)
                print(data.value(forKey: "sessionGoal") as! String? ?? "sessionGoal: nil")
                print(data.value(forKey: "sessionDate") as! Date)
                print(data.value(forKey: "sessionStartTime") as! Date)
                print(data.value(forKey: "sessionEndTime") as! Date)
                print(data.value(forKey: "sessionLength") as! Double)
                
                if (data.value(forKey: "sessionID") as! String? ?? "sessionID: nil") == "\(self.sessionID)" {
                    let date = Date()
                    data.setValue(date, forKey: "sessionEndTime")
                    
                    data.setValue(false, forKey: "isActive")
                    
                    let startDate = data.value(forKey: "sessionStartTime") as! Date
                    let sessionLength = startDate.distance(to: date)
                    print("sessionLength: ", sessionLength)
                    print("sessionLengthDouble: ", Double(sessionLength))

                    data.setValue(Double(sessionLength), forKey: "sessionLength")
                    
                    try context.save()
                }
            }
        } catch let error as NSError {
            print("Error when trying to fetch sessions: \(error), \(error.userInfo)")
        }
    }
}
