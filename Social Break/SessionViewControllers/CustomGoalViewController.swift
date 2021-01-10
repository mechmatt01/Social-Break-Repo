//
//  CustomGoalViewController.swift
//  Social Break
//
//  Created by Matthew Mech on 12/17/20.
//

import UIKit
import CoreData

class CustomGoalViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    var selectedTime: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addTapGestureRecogniserToView()
        
        self.backgroundView?.layer.cornerRadius = 20
        self.backgroundView?.layer.masksToBounds = true
        
        self.continueButton?.layer.cornerRadius = 9.5
        self.continueButton?.layer.masksToBounds = true
        self.continueButton?.addTarget(self, action: #selector(continueWithCustomGoal), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func continueWithCustomGoal() {
        let sessionVC = self.storyboard?.instantiateViewController(withIdentifier: "sessionViewController") as! sessionViewController
        sessionVC.modalPresentationStyle = .fullScreen
        sessionVC.sessionStatus = false
        sessionVC.selectedTime = selectedTime
        sessionVC.goalString = self.goalTextField?.text ?? ""
        self.present(sessionVC, animated: false, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -50 // Move view 50 points upward
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.goalTextField.resignFirstResponder()
        return true
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
