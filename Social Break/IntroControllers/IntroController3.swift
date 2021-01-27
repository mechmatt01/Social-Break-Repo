//
//  IntroController3.swift
//  Social Break
//
//  Created by Matthew Mech on 12/14/20.
//

import Foundation
import UIKit

class IntroController3: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var termsTextView: UITextView!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.continueButton?.addTarget(self, action: #selector(continueToNextStep), for: .touchUpInside)
        self.continueButton?.layer.cornerRadius = 15.5
        self.continueButton?.layer.masksToBounds = true
        
        let attributeFont = [NSAttributedString.Key.font: UIFont.SFProRoundedBoldFont(size: 13)]
        let copyrightText = NSMutableAttributedString(string:
        """
        By continuing you agree to the follow terms of use and privacy policy
        """, attributes: attributeFont)
        
        let hyperlinkedText = copyrightText.setAsLink(textToFind: "terms of use", linkURL: "http://www.socialbreak.info/termsofuse.html")
        let hyperlinkedText2 = copyrightText.setAsLink(textToFind: "privacy policy", linkURL: "http://www.socialbreak.info/privacy.html")
        
        if hyperlinkedText && hyperlinkedText2 {
            termsTextView.attributedText = NSAttributedString(attributedString: copyrightText)
            termsTextView.textAlignment = .center
            termsTextView.textColor = .white
        }
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
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:])
        return false
    }
}
