//
//  MainViewController.swift
//  Social Break
//
//  Created by Matthew Mech on 12/10/20.
//

import UIKit
import CoreData

class MainViewController: BasePageController {
    
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var startSessionButton: UIButton!
    @IBOutlet weak var scrollDownForMoreLabel: UILabel!
    @IBOutlet weak var scrollDownForMoreImage: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    
    var needUpdate: Bool = false
    
    var sessionGoal: String = ""
    var sessionLengthRemaining: Double = 0.0
    
    override var bgView: UIView {
        return self.backgroundView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if needUpdate == true {
            self.updateUsername()
        }
    }
    
    func checkSessionStatus() {
        self.startSessionButton?.isEnabled = false
        let whiteHalfColor = UIColor(white: 1.0, alpha: 0.5)
        let whiteFullColor = UIColor(white: 1.0, alpha: 1.0)
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let newBreakAttributedString = NSAttributedString(string: "New\nBreak", attributes: [NSAttributedString.Key.foregroundColor: whiteFullColor, NSAttributedString.Key.paragraphStyle: paragraph])
        let currentBreakAttributedString = NSAttributedString(string: "Current\nBreak", attributes: [NSAttributedString.Key.foregroundColor: whiteFullColor, NSAttributedString.Key.paragraphStyle: paragraph])
        let attributedString = NSAttributedString(string: "Loading...", attributes: [NSAttributedString.Key.foregroundColor: whiteHalfColor, NSAttributedString.Key.paragraphStyle: paragraph])
        self.startSessionButton?.setAttributedTitle(attributedString, for: .disabled)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Sessions")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
                let isActive = data.value(forKey: "isActive") as! Bool? ?? false
                
                let currentDate = Date()
                let sessionEndTime = data.value(forKey: "sessionEndTime") as! Date
                
                let sessionTimeRemaining = sessionEndTime.timeIntervalSince(currentDate)
                
                if isActive == true {
                    if sessionEndTime > currentDate && Double(sessionTimeRemaining) > 0.000 {
                        self.sessionGoal = data.value(forKey: "sessionGoal") as! String? ?? "nil"
                        self.sessionLengthRemaining = Double(sessionTimeRemaining)
                        self.startSessionButton?.setAttributedTitle(currentBreakAttributedString, for: .normal)
                        self.startSessionButton?.isEnabled = true
                        self.startSessionButton?.addTarget(self, action: #selector(continueSession), for: .touchUpInside)
                        return
                    } else {
                        data.setValue(false, forKey: "isActive")
                        do {
                            try context.save()
                            self.startSessionButton?.setAttributedTitle(newBreakAttributedString, for: .normal)
                            self.startSessionButton?.isEnabled = true
                            self.startSessionButton?.addTarget(self, action: #selector(startSession), for: .touchUpInside)
                            return
                        } catch let error as NSError {
                            print("Error when trying to save updated session info: \(error), \(error.userInfo)")
                            return
                        }
                    }
                }
            }
        } catch let error as NSError {
            print("Error when trying to fetch sessions: \(error), \(error.userInfo)")
            return
        }
        self.startSessionButton?.setAttributedTitle(newBreakAttributedString, for: .normal)
        self.startSessionButton?.isEnabled = true
        self.startSessionButton?.addTarget(self, action: #selector(startSession), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.checkSessionStatus()
        
        let dateFormatter = DateModel().dateFormatter(format: "EEEE, MMMM d")
        let mdy = dateFormatter.string(from: Date())
        self.dateLabel?.text = mdy
        
        self.dateLabel?.textAlignment = .left
        self.dateLabel?.adjustsFontSizeToFitWidth = true
        self.dateLabel?.minimumScaleFactor = 0.5
        
        self.introductionLabel?.textAlignment = .left
        self.introductionLabel?.minimumScaleFactor = 0.5
        self.introductionLabel?.adjustsFontSizeToFitWidth = true
        let hour = Calendar.current.component(.hour, from: Date())
        let userName = UserDefaults.standard.string(forKey: "userDisplayName")
        
        switch hour {
            case 4..<12 : self.introductionLabel?.text = ("Good Morning,\n\(userName!) ☕️")
            case 12..<17: self.introductionLabel?.text = ("Good Afternoon,\n\(userName!) ☀️")
            case 17..<22: self.introductionLabel?.text = ("Good Evening,\n\(userName!) 🌙")
            default     : self.introductionLabel?.text = ("Good Night,\n\(userName!) 💤")
        }
    }
    
    func updateUsername() {
        let userName = UserDefaults.standard.string(forKey: "userDisplayName")
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
            case 4..<12 : self.introductionLabel?.text = ("Good Morning,\n\(userName!) ☕️")
            case 12..<17: self.introductionLabel?.text = ("Good Afternoon,\n\(userName!) ☀️")
            case 17..<22: self.introductionLabel?.text = ("Good Evening,\n\(userName!) 🌙")
            default     : self.introductionLabel?.text = ("Good Night,\n\(userName!) 💤")
        }
    }
    
    @objc func continueSession() {
        let sessionVC = self.storyboard?.instantiateViewController(withIdentifier: "sessionViewController") as! sessionViewController
        sessionVC.modalPresentationStyle = .fullScreen
        sessionVC.sessionStatus = true
        sessionVC.selectedTime = sessionLengthRemaining
        sessionVC.goalString = sessionGoal
        self.present(sessionVC, animated: false, completion: nil)
    }

    @objc func startSession() {
        
        // If data needs to be cleared...
        /*
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Sessions")
        request.returnsObjectsAsFaults = false
        if let result = try? context.fetch(request) {
            for object in result as! [NSManagedObject] {
                context.delete(object)
            }
            do {
                try context.save()
            } catch let error as NSError {
                print("Error when trying to delete sessions: \(error), \(error.userInfo)")
            }
        }
        */
        
        self.performSegue(withIdentifier: "startSession", sender: self)
    }
}
