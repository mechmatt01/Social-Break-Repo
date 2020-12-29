//
//  MenuViewController.swift
//  Social Break
//
//  Created by Matthew Mech on 12/14/20.
//

import UIKit

class MenuViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var menuBarButton: UIButton!
    @IBOutlet var homeMenuButton: UIButton!
    @IBOutlet var statsMenuButton: UIButton!
    @IBOutlet var settingsMenuButton: UIButton!
    @IBOutlet var aboutMenuButton: UIButton!
    
    var comingFrom: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addTapGestureRecogniserToView()
        
        self.homeMenuButton?.setTitleColor(UIColor(red: 0.576, green: 0.576,blue: 0.576,alpha: 1.000), for: .highlighted)
        self.statsMenuButton?.setTitleColor(UIColor(red: 0.576, green: 0.576,blue: 0.576,alpha: 1.000), for: .highlighted)
        self.settingsMenuButton?.setTitleColor(UIColor(red: 0.576, green: 0.576,blue: 0.576,alpha: 1.000), for: .highlighted)
        self.aboutMenuButton?.setTitleColor(UIColor(red: 0.576, green: 0.576,blue: 0.576,alpha: 1.000), for: .highlighted)
        
        self.menuBarButton?.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        self.homeMenuButton?.addTarget(self, action: #selector(goToHomeVC), for: .touchUpInside)
        self.statsMenuButton?.addTarget(self, action: #selector(goToStatsVC), for: .touchUpInside)
        self.settingsMenuButton?.addTarget(self, action: #selector(goToSettingsVC), for: .touchUpInside)
        self.aboutMenuButton?.addTarget(self, action: #selector(goToAboutVC), for: .touchUpInside)
        
        if comingFrom == "mainVC" {
            self.homeMenuButton?.isHighlighted = true
        }  else if comingFrom == "statsVC" {
            self.statsMenuButton?.isHighlighted = true
        } else if comingFrom == "settingsVC" {
            self.settingsMenuButton?.isHighlighted = true
        } else if comingFrom == "aboutVC" {
            self.aboutMenuButton?.isHighlighted = true
        }
    }
    
    @objc func goToHomeVC() {
        self.performSegue(withIdentifier: "goToHomeVC", sender: self)
    }
    
    @objc func goToStatsVC() {
        self.performSegue(withIdentifier: "goToStatsVC", sender: self)
    }
    
    @objc func goToSettingsVC() {
        self.performSegue(withIdentifier: "goToSettingsVC", sender: self)
    }
    
    @objc func goToAboutVC() {
        self.performSegue(withIdentifier: "goToAboutVC", sender: self)
    }
    
    override var prefersStatusBarHidden: Bool {
      return false
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
    
    @objc func dismissView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            
            self.backgroundView.alpha = 0
            self.menuBarButton.alpha = 0
            self.homeMenuButton.alpha = 0
            self.statsMenuButton.alpha = 0
            self.settingsMenuButton.alpha = 0
            self.aboutMenuButton.alpha = 0
            
        }) { (success: Bool) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
