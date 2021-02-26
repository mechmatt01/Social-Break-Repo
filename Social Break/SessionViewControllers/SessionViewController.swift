//
//  SessionViewController.swift
//  Social Break
//
//  Created by Matthew Mech on 12/14/20.
//

import UIKit
import CoreData
import AVFoundation

class sessionViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var goal: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var timer: Timer?
    var timeTimer = Timer()
    
    var endTime: Date = Date()
    var selectedTime: Double = 0.0
    var goalString: String = ""
    var sessionID: String = ""
    var randomString = ""
    
    var player: AVAudioPlayer?
    var playerCompleted: AVAudioPlayer?
    var isPlayerPlaying = false
    
    // True = In Progress
    // False = Not Started
    var sessionStatus: Bool = false
    
    let uuidString = UUID().uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminateNotification), name: UIApplication.willTerminateNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playSoundSession), name: Notification.Name("playSoundSession"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endSession), name: Notification.Name("endSession"), object: nil)
        
        if UserDefaults.standard.string(forKey: "backgroundImage") ?? "BackgroundImage1" == "BackgroundImage1" {
            self.backgroundImageView?.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.250)
        } else {
            self.backgroundImageView?.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500)
        }
        
        self.goal?.text = goalString
        
        self.selectedTime = self.selectedTime + 1.0
        
        self.startButton?.layer.cornerRadius = 62.5
        self.startButton?.layer.masksToBounds = true
        self.startButton?.addTarget(self, action: #selector(startTimer), for: .touchUpInside)
        
        self.currentTimeLabel?.text = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
        self.timeTimer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector:#selector(self.timeUpdate), userInfo: nil, repeats: true)
        
        if sessionStatus == true {
            self.timeRemainingLabel?.alpha = 1.0
            self.continueTimer()
        } else {
            self.timeRemainingLabel?.alpha = 0.0
        }
        
        self.backgroundImage?.image = UIImage(named: "\(UserDefaults.standard.string(forKey: "backgroundImage") ?? "BackgroundImage1")")
        self.backgroundImage?.contentMode = .scaleAspectFill
        
        self.optionsButton?.addTarget(self, action: #selector(showSessionOptions), for: .touchUpInside)
    }
    
    @objc func willTerminateNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [self.uuidString])
        
        print("willTerminateNotification")
        
        let content = UNMutableNotificationContent()
        content.title = "Social Break Closed"
        content.body = "Reopen Social Break to continue your active break"
        
        let uuidStringClosedApp = UUID().uuidString
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(3), repeats: false)
        let request = UNNotificationRequest(identifier: uuidStringClosedApp, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if error != nil {
                print("Error: ", error?.localizedDescription ?? "nil")
            }
        }
    }
    
    @objc func applicationDidEnterBackground() {
        print("applicationDidEnterBackground")
    }
    
    @objc func applicationDidBecomeActive() {
        print("applicationDidBecomeActive")
        self.continueTimerAfterBackground()
    }
    
    func continueTimerAfterBackground() {
        
        self.timer?.invalidate()
        
        print("self.endTime.timeIntervalSinceNow: ", self.endTime.timeIntervalSinceNow)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            
            self.selectedTime -= 1
            self.selectedTime = self.endTime.timeIntervalSinceNow
            
            let selectedTimeInt = Int(self.endTime.timeIntervalSinceNow)
            
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .positional
            
            let formattedString = formatter.string(from: TimeInterval(selectedTimeInt))!
            self.timeRemainingLabel.text = formattedString
            
            if self.selectedTime <= 0 {
                self.sessionEndUpdateDataFields()
                self.sessionCompletePlaySound()
                timer.invalidate()
                self.timeRemainingLabel.font = UIFont.SFProRoundedBoldFont(size: 30)
                self.timeRemainingLabel.numberOfLines = 2
                self.timeRemainingLabel.text = "Completed at \(DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short))"
            }
        }
    }
    
    func continueTimer() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Sessions")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
                let isActive = data.value(forKey: "isActive") as! Bool? ?? false
                
                if isActive == true {
                    
                    data.setValue(false, forKey: "isActive")
                    do {
                        try context.save()
                    } catch let error as NSError {
                        print("Error when trying to save updated session info: \(error), \(error.userInfo)")
                    }
                }
            }
        } catch let error as NSError {
            print("Error when trying to fetch sessions: \(error), \(error.userInfo)")
            return
        }
        
        
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
            
            let secondsInt = Int(self.selectedTime)
            
            // does this lead to anything?
            let dateCurrentFormatter = DateModel().dateFormatter(format: "yyyy-MM-dd'T'HH:mm:ssZ")
            
            let endTimeOfSession = Calendar.current.date(byAdding: .second, value: secondsInt, to: Date())!
            self.endTime = endTimeOfSession
            
            newSession.setValue(sessionID, forKey: "sessionID")
            newSession.setValue(true, forKey: "isActive")
            newSession.setValue(self.goalString, forKey: "sessionGoal")
            newSession.setValue(currentDate, forKey: "sessionDate")
            newSession.setValue(currentDate, forKey: "sessionStartTime")
            newSession.setValue(endTimeOfSession, forKey: "sessionEndTime")
            newSession.setValue(0.0, forKey: "sessionLength")
            
            do {
                try context.save()
            } catch let error as NSError {
                print("Error when trying to save new session: \(error), \(error.userInfo)")
            }
            
            // does this lead to anything?
            let dateFormatter = DateModel().dateFormatter(format: "h:m a")
            
            let content = UNMutableNotificationContent()
            content.title = "\(self.goalString) Break Ended"
            content.body = "Ended at \(DateFormatter.localizedString(from: endTimeOfSession, dateStyle: .none, timeStyle: .short))"
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(secondsInt), repeats: false)
            let request = UNNotificationRequest(identifier: self.uuidString, content: content, trigger: trigger)
            
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
                if error != nil {
                    print("Error: ", error?.localizedDescription ?? "nil")
                }
            }
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                
                self.selectedTime -= 1
                
                let selectedTimeInt = Int(self.selectedTime)
                
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.hour, .minute, .second]
                formatter.unitsStyle = .positional
                
                let formattedString = formatter.string(from: TimeInterval(selectedTimeInt))!
                self.timeRemainingLabel.text = formattedString
                
                if self.selectedTime <= 0 {
                    self.sessionEndUpdateDataFields()
                    self.sessionCompletePlaySound()
                    timer.invalidate()
                    self.timeRemainingLabel.font = UIFont.SFProRoundedBoldFont(size: 30)
                    self.timeRemainingLabel.numberOfLines = 2
                    self.timeRemainingLabel.text = "Completed at \(DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short))"
                }
            }
        }
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
            
            let secondsInt = Int(self.selectedTime)
            
            // refactored, but it seems like dateCurrentFormatter is not used anywhere else.
            let dateCurrentFormatter = DateModel().dateFormatter(format: "yyyy-MM-dd'T'HH:mm:ssZ")
            
            let endTimeOfSession = Calendar.current.date(byAdding: .second, value: secondsInt, to: Date())!
            self.endTime = endTimeOfSession
            
            newSession.setValue(sessionID, forKey: "sessionID")
            newSession.setValue(true, forKey: "isActive")
            newSession.setValue(self.goalString, forKey: "sessionGoal")
            newSession.setValue(currentDate, forKey: "sessionDate")
            newSession.setValue(currentDate, forKey: "sessionStartTime")
            newSession.setValue(endTimeOfSession, forKey: "sessionEndTime")
            newSession.setValue(0.0, forKey: "sessionLength")
            
            do {
                try context.save()
            } catch let error as NSError {
                print("Error when trying to save new session: \(error), \(error.userInfo)")
            }
            
            let dateFormatter = DateModel().dateFormatter(format: "h:m a")
            print(dateFormatter.string(from: endTimeOfSession))
            
            let content = UNMutableNotificationContent()
            content.title = "\(self.goalString) Break Ended"
            content.body = "Ended at \(DateFormatter.localizedString(from: endTimeOfSession, dateStyle: .none, timeStyle: .short))"
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(secondsInt), repeats: false)
            let request = UNNotificationRequest(identifier: self.uuidString, content: content, trigger: trigger)
            
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
                if error != nil {
                    print("Error: ", error?.localizedDescription ?? "nil")
                }
            }
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                
                self.selectedTime -= 1
                
                let selectedTimeInt = Int(self.selectedTime)
                
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.hour, .minute, .second]
                formatter.unitsStyle = .positional
                
                let formattedString = formatter.string(from: TimeInterval(selectedTimeInt))!
                self.timeRemainingLabel.text = formattedString
                
                if self.selectedTime <= 0 {
                    self.sessionEndUpdateDataFields()
                    self.sessionCompletePlaySound()
                    timer.invalidate()
                    self.timeRemainingLabel.font = UIFont.SFProRoundedBoldFont(size: 30)
                    self.timeRemainingLabel.numberOfLines = 2
                    self.timeRemainingLabel.text = "Completed at \(DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short))"
                }
            }
        }
    }
    
    @objc func showSessionOptions() {
        let optionsVC = self.storyboard?.instantiateViewController(withIdentifier: "sessionOptionsVC") as! SessionOptionsViewController
        optionsVC.isTimerActive = ((timer?.isValid) != nil)
        optionsVC.isSoundActive = isPlayerPlaying
        optionsVC.modalPresentationStyle = .overCurrentContext
        self.present(optionsVC, animated: false, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func timeUpdate() {
        self.currentTimeLabel?.text = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
    }
    
    @objc func playSoundSession(notification: NSNotification) {
        
        let filePath = UserDefaults.standard.string(forKey: "soundPath") ?? ""
        let url = URL(fileURLWithPath: filePath)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            
            player?.numberOfLoops = -1
            if isPlayerPlaying == false {
                player?.play()
                isPlayerPlaying = true
            } else {
                player?.pause()
                isPlayerPlaying = false
            }
            
        } catch let error {
            print("Error for AVPlayer: ", error.localizedDescription)
        }
    }
    
    @objc func endSession(notification: NSNotification) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [self.uuidString])
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("playSoundSession"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("endSession"), object: nil)
        
        if timer?.isValid == true  {
            let alertController = UIAlertController(title: "Are You Sure?", message: "This will end your session.", preferredStyle: .alert)
            let continueAction = UIAlertAction(title: "End Session", style: .destructive) { (_) -> Void in
                self.sessionEndUpdateDataFields()
                UIView.animate(withDuration: 0.3, animations: {
                    self.backgroundImage?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                    
                    self.currentTimeLabel?.alpha = 0
                    self.optionsButton?.alpha = 0
                    self.timeRemainingLabel?.alpha = 0
                    self.backgroundImage?.alpha = 0
                    
                }) { (success: Bool) in
                    self.timer?.invalidate()
                    self.timeTimer.invalidate()
                    self.player?.stop()
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
                self.backgroundImage?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                
                self.currentTimeLabel?.alpha = 0
                self.optionsButton?.alpha = 0
                self.timeRemainingLabel?.alpha = 0
                self.backgroundImage?.alpha = 0
                
            }) { (success: Bool) in
                self.timer?.invalidate()
                self.timeTimer.invalidate()
                self.player?.stop()
                let mainVC = MainPageViewController()
                mainVC.modalPresentationStyle = .fullScreen
                if #available(iOS 13.0, *) {
                    mainVC.isModalInPresentation = true
                }
                self.present(mainVC, animated: false, completion: nil)
            }
        }
    }
    
    @objc func dismissView() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [self.uuidString])
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("playSoundSession"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("endSession"), object: nil)
        
        if timer?.isValid == true  {
            let alertController = UIAlertController(title: "Are You Sure?", message: "This will end your session.", preferredStyle: .alert)
            let continueAction = UIAlertAction(title: "End Session", style: .destructive) { (_) -> Void in
                self.sessionEndUpdateDataFields()
                UIView.animate(withDuration: 0.3, animations: {
                    self.backgroundImage.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                    
                    self.currentTimeLabel.alpha = 0
                    self.optionsButton.alpha = 0
                    self.timeRemainingLabel.alpha = 0
                    self.backgroundImage.alpha = 0
                    
                }) { (success: Bool) in
                    self.timer?.invalidate()
                    self.timeTimer.invalidate()
                    self.player?.stop()
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
                self.optionsButton.alpha = 0
                self.timeRemainingLabel.alpha = 0
                self.backgroundImage.alpha = 0
                
            }) { (success: Bool) in
                self.timer?.invalidate()
                self.timeTimer.invalidate()
                self.player?.stop()
                let mainVC = MainPageViewController()
                mainVC.modalPresentationStyle = .fullScreen
                if #available(iOS 13.0, *) {
                    mainVC.isModalInPresentation = true
                }
                self.present(mainVC, animated: false, completion: nil)
            }
        }
    }
    
    func sessionCompletePlaySound() {
        guard let path = Bundle.main.path(forResource: "Completed.mp3", ofType: nil) else {
            print("Cannot find object in path")
            return
        }
        let url = URL(fileURLWithPath: path)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            playerCompleted = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            self.player?.pause()
            playerCompleted?.numberOfLoops = 1
            playerCompleted?.play()
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                self.player?.play()
            })
        } catch let error {
            print("Error for AVPlayer Completed: ", error.localizedDescription)
        }
    }
    
    func sessionEndUpdateDataFields() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Sessions")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
                if (data.value(forKey: "sessionID") as! String? ?? "sessionID: nil") == "\(self.sessionID)" {
                    let date = Date()
                    data.setValue(date, forKey: "sessionEndTime")
                    
                    data.setValue(false, forKey: "isActive")
                    
                    let startDate = data.value(forKey: "sessionStartTime") as! Date
                    let sessionLength = startDate.distance(to: date)
                    
                    data.setValue(Double(sessionLength), forKey: "sessionLength")
                    
                    try context.save()
                }
            }
        } catch let error as NSError {
            print("Error when trying to fetch sessions: \(error), \(error.userInfo)")
        }
    }

}
