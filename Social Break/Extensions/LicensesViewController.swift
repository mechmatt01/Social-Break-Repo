//
//  LicenseViewController.swift
//  Social Break
//
//  Created by Matthew Mech on 12/29/20.
//

import UIKit

class LicenseViewController: UIViewController, UITextViewDelegate {
    
    var selectedIndex: String = ""
    
    @IBOutlet weak var sourceName: UILabel!
    @IBOutlet weak var copyrightInformation: UITextView!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.closeButton?.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        if selectedIndex == "icons8" {
            sourceName.text = "icons8"
            let copyrightText = NSMutableAttributedString(string:
            """
            Some images and icons used in this app are created by icons8.
            """)
            let hyperlinkedText = copyrightText.setAsLink(textToFind: "icons8", linkURL: "https://www.icons8.com")
            
            if hyperlinkedText {
                copyrightInformation.attributedText = NSAttributedString(attributedString: copyrightText)
                copyrightInformation.textColor = .white
            }
        } else if selectedIndex == "unsplash" {
            sourceName.text = "Unsplash"
            let copyrightText = NSMutableAttributedString(string:
            """
            Background images are from from Unsplash.
            """)
            let hyperlinkedText = copyrightText.setAsLink(textToFind: "Unsplash", linkURL: "https://www.unsplash.com")
            
            if hyperlinkedText {
                copyrightInformation.attributedText = NSAttributedString(attributedString: copyrightText)
                copyrightInformation.textColor = .white
            }
        } else {
            self.dismiss(animated: true, completion: nil)
            sourceName.text = "No License Selected"
            copyrightInformation.text = ""
        }
        
        sourceName.font = UIFont.SFProRoundedBoldFont(size: 22)
        sourceName.minimumScaleFactor = 0.5
        sourceName.textAlignment = .center
        sourceName.backgroundColor = .clear
        
        copyrightInformation.delegate = self
        copyrightInformation.font = UIFont.SFProRoundedBoldFont(size: 18)
        copyrightInformation.textAlignment = .center
        copyrightInformation.backgroundColor = .clear
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:])
        return false
    }
}
