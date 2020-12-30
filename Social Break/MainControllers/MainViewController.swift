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
    
    override var bgView: UIView {
        return self.backgroundView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if needUpdate == true {
            self.updateUsername()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startSessionButton?.addTarget(self, action: #selector(startSession), for: .touchUpInside)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
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
