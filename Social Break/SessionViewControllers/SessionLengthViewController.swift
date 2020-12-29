//
//  SessionLengthViewController.swift
//  Social Break
//
//  Created by Matthew Mech on 12/14/20.
//

import Foundation
import UIKit

class sessionLengthViewController: UIViewController {
    
    /*
     Quick Break: 1 min
     Short Break: 15 min
     Full Break: 30 min
     Extended Break: 1 hr
     Custom Break: 1 min - 24 hr
         Warn about battery usage for over 3 hours of break time (if user leaves device screen on)
     */
    
    @IBOutlet weak var quickBreak: UIButton!
    @IBOutlet weak var quickBreakFXView: UIVisualEffectView!
    @IBOutlet weak var shortBreak: UIButton!
    @IBOutlet weak var shortBreakFXView: UIVisualEffectView!
    @IBOutlet weak var fullBreak: UIButton!
    @IBOutlet weak var fullBreakFXView: UIVisualEffectView!
    @IBOutlet weak var extendedBreak: UIButton!
    @IBOutlet weak var extendedBreakFXView: UIVisualEffectView!
    @IBOutlet weak var customBreak: UIButton!
    @IBOutlet weak var customBreakFXView: UIVisualEffectView!
    @IBOutlet weak var breakOptionsStackView: UIStackView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.string(forKey: "backgroundImage") ?? "BackgroundImage1" == "BackgroundImage1" {
            self.backgroundImageView?.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.250)
        } else {
            self.backgroundImageView?.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500)
        }
        
        self.quickBreakFXView?.layer.masksToBounds = true
        self.quickBreakFXView?.layer.cornerRadius = (self.quickBreakFXView?.contentView.frame.height)! / 4
        self.shortBreakFXView?.layer.masksToBounds = true
        self.shortBreakFXView?.layer.cornerRadius = (self.shortBreakFXView?.contentView.frame.height)! / 4
        self.fullBreakFXView?.layer.masksToBounds = true
        self.fullBreakFXView?.layer.cornerRadius = (self.fullBreakFXView?.contentView.frame.height)! / 4
        self.extendedBreakFXView?.layer.masksToBounds = true
        self.extendedBreakFXView?.layer.cornerRadius = (self.extendedBreakFXView?.contentView.frame.height)! / 4
        self.customBreakFXView?.layer.masksToBounds = true
        self.customBreakFXView?.layer.cornerRadius = (self.customBreakFXView?.contentView.frame.height)! / 4
        
        self.cancelButton?.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        self.quickBreak?.addTarget(self, action: #selector(goToGoalVC(sender:)), for: .touchUpInside)
        self.quickBreak?.tag = 60
        self.shortBreak?.addTarget(self, action: #selector(goToGoalVC(sender:)), for: .touchUpInside)
        self.shortBreak?.tag = 900
        self.fullBreak?.addTarget(self, action: #selector(goToGoalVC(sender:)), for: .touchUpInside)
        self.fullBreak?.tag = 1800
        self.extendedBreak?.addTarget(self, action: #selector(goToGoalVC(sender:)), for: .touchUpInside)
        self.extendedBreak?.tag = 3600
        self.customBreak?.addTarget(self, action: #selector(customBreakTime), for: .touchUpInside)
        
        self.backgroundImage?.image = UIImage(named: "\(UserDefaults.standard.string(forKey: "backgroundImage") ?? "BackgroundImage1")")
        self.backgroundImage?.contentMode = .scaleAspectFill
    }
    
    @objc func goToGoalVC(sender: UIButton) {
        let sessionGoalVC = self.storyboard?.instantiateViewController(withIdentifier: "goalViewController") as! SessionGoalViewController
        sessionGoalVC.modalPresentationStyle = .fullScreen
        sessionGoalVC.selectedTime = Double(sender.tag)
        self.present(sessionGoalVC, animated: false, completion: nil)
    }
    
    @objc func customBreakTime() {
        let customVC = self.storyboard?.instantiateViewController(withIdentifier: "customTimeViewController") as! CustomTimeViewController
        customVC.modalPresentationStyle = .overCurrentContext
        self.present(customVC, animated: false, completion: nil)
    }
    
    @objc func dismissView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundImage.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            
            self.quickBreak.alpha = 0
            self.quickBreakFXView.alpha = 0
            self.shortBreak.alpha = 0
            self.shortBreakFXView.alpha = 0
            self.fullBreak.alpha = 0
            self.fullBreakFXView.alpha = 0
            self.extendedBreak.alpha = 0
            self.extendedBreakFXView.alpha = 0
            self.customBreak.alpha = 0
            self.customBreakFXView.alpha = 0
            self.breakOptionsStackView.alpha = 0
            self.cancelButton.alpha = 0
            self.backgroundImage.alpha = 0
            
        }) { (success: Bool) in
            self.dismiss(animated: true, completion: nil)
        }
    }
}
