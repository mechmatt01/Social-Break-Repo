//
//  IntroController3.swift
//  Social Break
//
//  Created by Matthew Mech on 12/14/20.
//

import Foundation
import UIKit

class IntroController3: UIViewController {
    
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.continueButton?.addTarget(self, action: #selector(continueToNextStep), for: .touchUpInside)
        self.continueButton?.layer.cornerRadius = 15.5
        self.continueButton?.layer.masksToBounds = true
    }
    
    @objc func continueToNextStep() {
        UserDefaults.standard.set(true, forKey: "hasCompletedIntro")
        let mainVC = MainPageViewController()
        mainVC.modalPresentationStyle = .fullScreen
        if #available(iOS 13.0, *) {
            mainVC.isModalInPresentation = true
        }
        self.present(mainVC, animated: true, completion: nil)
    }
}
