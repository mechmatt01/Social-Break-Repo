//
//  IntroController1.swift
//  Social Break
//
//  Created by Matthew Mech on 12/12/20.
//

import Foundation
import UIKit

class IntroController1: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.resetDefaults()
        
        self.continueButton?.addTarget(self, action: #selector(continueToNextStep), for: .touchUpInside)
        self.continueButton?.layer.cornerRadius = 15.5
        self.continueButton?.layer.masksToBounds = true
        self.continueButton?.isEnabled = false
        
        self.nameTextField?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
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
    
    @objc func continueToNextStep() {
        if self.nameTextField.hasText == true && self.nameTextField.text?.isEmpty == false {
            UserDefaults.standard.set("\(self.nameTextField.text ?? "")", forKey: "userDisplayName")
            UserDefaults.standard.set("BackgroundImage1", forKey: "backgroundImage")
            self.performSegue(withIdentifier: "goToStep2", sender: self)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.nameTextField.hasText == true && self.nameTextField.text?.isEmpty == false {
            self.continueButton?.isEnabled = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nameTextField.resignFirstResponder()
        return true
    }
}
