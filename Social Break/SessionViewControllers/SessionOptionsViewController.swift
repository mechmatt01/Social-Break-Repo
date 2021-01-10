//
//  SessionOptionsViewController.swift
//  Social Break
//
//  Created by Matthew Mech on 1/8/21.
//

import UIKit

class SessionOptionsViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var endSessionButton: UIButton!
    @IBOutlet weak var soundButton: UIButton!
    
    var isTimerActive: Bool = true
    var isSoundActive: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isSoundActive == true {
            self.soundButton?.setImage(UIImage(named: "SessionOptionSoundOff"), for: .normal)
        } else {
            self.soundButton?.setImage(UIImage(named: "SessionOptionSoundOn"), for: .normal)
        }
        
        //self.soundButton?.titleLabel?.textAlignment = .center
        //self.endSessionButton?.titleLabel?.textAlignment = .center
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addTapGestureRecogniserToView()
        
        self.cancelButton?.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        self.soundButton?.addTarget(self, action: #selector(playSoundSession), for: .touchUpInside)
        self.endSessionButton?.addTarget(self, action: #selector(endSession), for: .touchUpInside)
        
        self.soundButton?.centerVertically(padding: 6.0)
        self.endSessionButton?.centerVertically(padding: 6.0)
    }
    
    func addTapGestureRecogniserToView() {
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        tapGestureRecogniser.numberOfTapsRequired = 1
        tapGestureRecogniser.delegate = self
        tapGestureRecogniser.delaysTouchesBegan = true
        tapGestureRecogniser.cancelsTouchesInView = false
        backgroundView.addGestureRecognizer(tapGestureRecogniser)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchedView = touch.view , touchedView == self.backgroundView {
            return true
        }
        return false
    }
    
    @objc func playSoundSession() {
        NotificationCenter.default.post(name: Notification.Name("playSoundSession"), object: nil)
        self.dismissView()
    }
    
    @objc func endSession() {
        self.dismissView()
        NotificationCenter.default.post(name: Notification.Name("endSession"), object: nil)
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
}
