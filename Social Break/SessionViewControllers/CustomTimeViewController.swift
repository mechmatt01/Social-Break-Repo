//
//  CustomTimeViewController.swift
//  Social Break
//
//  Created by Matthew Mech on 12/16/20.
//

import UIKit

class CustomTimeViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addTapGestureRecogniserToView()
        
        self.backgroundView?.layer.cornerRadius = 30
        self.backgroundView?.layer.masksToBounds = true
        
        self.continueButton?.layer.cornerRadius = 9.5
        self.continueButton?.layer.masksToBounds = true
        self.continueButton?.addTarget(self, action: #selector(continueWithCustomTime), for: .touchUpInside)
        
        self.datePicker?.overrideUserInterfaceStyle = .dark
    }
    
    @objc func continueWithCustomTime() {
        
        if self.datePicker?.countDownDuration ?? 0.0 >= 10800.00 {
            let alertController = UIAlertController(title: "Are You Sure?", message: "This may consume more of your battery by setting a timer for this long.", preferredStyle: .alert)
            let continueAction = UIAlertAction(title: "Continue", style: .default) { (_) -> Void in
                let sessionGoalVC = self.storyboard?.instantiateViewController(withIdentifier: "goalViewController") as! SessionGoalViewController
                sessionGoalVC.modalPresentationStyle = .fullScreen
                sessionGoalVC.selectedTime = self.datePicker?.countDownDuration ?? 0.0
                self.present(sessionGoalVC, animated: false, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(continueAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            let sessionGoalVC = self.storyboard?.instantiateViewController(withIdentifier: "goalViewController") as! SessionGoalViewController
            sessionGoalVC.modalPresentationStyle = .fullScreen
            sessionGoalVC.selectedTime = self.datePicker?.countDownDuration ?? 0.0
            self.present(sessionGoalVC, animated: false, completion: nil)
        }
    }
    
    func addTapGestureRecogniserToView() {
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        tapGestureRecogniser.numberOfTapsRequired = 1
        tapGestureRecogniser.delegate = self
        tapGestureRecogniser.delaysTouchesBegan = true
        tapGestureRecogniser.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecogniser)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchedView = touch.view , touchedView == self.view {
            return true
        }
        return false
    }
    
    @objc func dismissView() {
        self.dismiss(animated: false, completion: nil)
    }
}
