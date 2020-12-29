//
//  StatsViewController.swift
//  Social Break
//
//  Created by Matthew Mech on 12/14/20.
//

import UIKit
import CoreData

class StatsViewController: BasePageController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var todayTotalTimeLabel: UILabel!
    @IBOutlet weak var todayTotalBreaksLabel: UILabel!
    @IBOutlet weak var weekTotalTimeLabel: UILabel!
    @IBOutlet weak var weekTotalBreaksLabel: UILabel!
    @IBOutlet weak var allTimeTotalTimeLabel: UILabel!
    @IBOutlet weak var allTimeTotalBreaksLabel: UILabel!
    
    let screenType = "\(UIDevice.current.screenType)"
    
    var todaysTotalSessions = 0
    var thisWeeksTotalSessions = 0
    var allTimeTotalSessions = 0
    var allTimeTotalSessionsCheck = 0
    
    var todaysTotalTime = 0.0
    var thisWeeksTotalTime = 0.0
    var allTimeTotalTime = 0.0
    var allTimeTotalTimeCheck = 0.0
    
    override var bgView: UIView {
        return self.backgroundView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.screenType == "iPhones_SE" {
            if let view = self.stackView?.arrangedSubviews[1] {
                view.removeFromSuperview()
            }
        }

       self.getStatsData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.getUpdatedStatsData()
    }
    
    func getUpdatedStatsData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Sessions")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
                let sessionLength = data.value(forKey: "sessionLength") as! Double
                
                self.allTimeTotalTimeCheck += sessionLength
                self.allTimeTotalSessionsCheck += 1
            }

            if self.allTimeTotalSessionsCheck != self.allTimeTotalSessions && self.allTimeTotalTimeCheck != self.allTimeTotalTime {
                self.getStatsData()
            }
        } catch let error as NSError {
            print("Error when trying to fetch sessions: \(error), \(error.userInfo)")
        }
    }
    
    func getStatsData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Sessions")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
                print()
                print("Session Info")
                print("sessionID: ", data.value(forKey: "sessionID") as! String? ?? "sessionID: nil")
                print("isActive: ", data.value(forKey: "isActive") as! Bool? ?? false)
                print("sessionGoal: ", data.value(forKey: "sessionGoal") as! String? ?? "sessionGoal: nil")
                print("sessionDate: ", data.value(forKey: "sessionDate") as! Date)
                print("sessionStartTime: ", data.value(forKey: "sessionStartTime") as! Date)
                print("sessionEndTime: ", data.value(forKey: "sessionEndTime") as! Date)
                print("sessionLength: ", data.value(forKey: "sessionLength") as! Double)
                print()
                
                let sessionLength = data.value(forKey: "sessionLength") as! Double
                
                let tommorrowsDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
                let startOfTomorrow = Calendar.current.startOfDay(for: tommorrowsDate)
                let startOfToday = Calendar.current.startOfDay(for: Date())
               
                let sessionDate = data.value(forKey: "sessionDate") as! Date
            
                print("startOfToday: ", startOfToday)
                
                if Calendar.current.isDayInCurrentWeek(date: sessionDate) ?? false == true {
                    // Occurred This Week
                    if sessionDate.isBetween(startOfToday, and: startOfTomorrow) == true {
                        // Occurred Today
                        self.todaysTotalTime += sessionLength
                        self.todaysTotalSessions += 1
                        self.thisWeeksTotalTime += sessionLength
                        self.thisWeeksTotalSessions += 1
                    } else {
                        // Occurred This Week
                        self.thisWeeksTotalTime += sessionLength
                        self.thisWeeksTotalSessions += 1
                    }
                }
                
                self.allTimeTotalTime += sessionLength
                self.allTimeTotalSessions += 1
            }
            
            self.todayTotalTimeLabel.fadeTransition(0.2)
            self.todayTotalTimeLabel.text = self.setTimeData(totalTime: todaysTotalTime)
            self.todayTotalBreaksLabel.fadeTransition(0.2)
            self.todayTotalBreaksLabel.text = "\(self.todaysTotalSessions)"
            if self.screenType != "iPhones_SE" {
                self.weekTotalTimeLabel.fadeTransition(0.2)
                self.weekTotalTimeLabel.text = self.setTimeData(totalTime: thisWeeksTotalTime)
                self.weekTotalBreaksLabel.fadeTransition(0.2)
                self.weekTotalBreaksLabel.text = "\(self.thisWeeksTotalSessions)"
            }
            self.allTimeTotalTimeLabel.fadeTransition(0.2)
            self.allTimeTotalTimeLabel.text = self.setTimeData(totalTime: allTimeTotalTime)
            self.allTimeTotalBreaksLabel.fadeTransition(0.2)
            self.allTimeTotalBreaksLabel.text = "\(self.allTimeTotalSessions)"
        } catch let error as NSError {
            print("Error when trying to fetch sessions: \(error), \(error.userInfo)")
        }
    }
    
    func setTimeData(totalTime: Double) -> String {
        
        var timeString = ""
        
        if totalTime == 0.00 {
            timeString = "0"
        } else {
            let selectedTimeInt = Int(totalTime)
            let hours = String(selectedTimeInt / 3600)
            let minutes = String((selectedTimeInt % 3600) / 60)
            let seconds = String((selectedTimeInt % 3600) % 60)
            
            if hours == "0" && minutes == "0" {
                timeString = seconds + " sec"
            } else if hours == "0" {
                timeString = minutes + "." + seconds + " min"
            } else {
                timeString = hours + " hr " + minutes + " min " + seconds + " sec"
            }
        }
        
        return timeString
    }
    
    @objc func swipedScreenDown(swipeGesture: UISwipeGestureRecognizer) {
        self.performSegue(withIdentifier: "swipeDownToMain", sender: self)
    }
    
    @objc func swipedScreenUp(swipeGesture: UISwipeGestureRecognizer) {
        self.performSegue(withIdentifier: "swipeUpToSettings", sender: self)
    }
}
