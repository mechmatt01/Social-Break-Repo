//
//  IntroController3.swift
//  Social Break
//
//  Created by Matthew Mech on 12/14/20.
//

import Foundation
import UIKit
import FirebaseStorage

class IntroController3: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var termsTextView: UITextView!
    @IBOutlet weak var continueButton: UIButton!
    
    let storage = Storage.storage()
    
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
        let soundName = "ForestSound.wav"
        
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsUrl.appendingPathComponent("\(soundName)")
        
        let storageRef = storage.reference()
        let audioRef = storageRef.child("Audio/\(soundName)")
        
        let downloadTask = audioRef.write(toFile: destinationUrl) { url, error in
          if let error = error {
            // An error occurred
            print("Error writing file: \(error.localizedDescription)")
          } else {
            print("File found")
          }
        }
        
        let newBackgroundView = UIView()
        newBackgroundView.layer.backgroundColor = UIColor(white: 0.5, alpha: 0.5).cgColor
        newBackgroundView.frame = UIScreen.main.bounds
        view.addSubview(newBackgroundView)
        let progressIndicator = UIProgressView()
        progressIndicator.frame = CGRect(x: Int(UIScreen.main.bounds.midX) / 2, y: Int(UIScreen.main.bounds.midY), width: Int(UIScreen.main.bounds.width / 2), height: 10)
        progressIndicator.progressTintColor = UIColor.white
        progressIndicator.progressViewStyle = .bar
        let progressLabel = UILabel()
        progressLabel.text = "Downloading Sound..."
        progressLabel.font = UIFont.SFProRoundedBoldFont(size: 18)
        progressLabel.textColor = UIColor.white
        progressLabel.frame = CGRect(x: Int(UIScreen.main.bounds.midX) / 2, y: Int(UIScreen.main.bounds.midY), width: Int(UIScreen.main.bounds.width / 2), height: 40)
        newBackgroundView.addSubview(progressLabel)
        newBackgroundView.addSubview(progressIndicator)
        
        downloadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            print(percentComplete)
            progressIndicator.setProgress(Float(percentComplete), animated: false)
            print(snapshot.progress!.isFinished)
            if snapshot.progress!.isFinished == true {
                progressIndicator.removeFromSuperview()
                progressLabel.removeFromSuperview()
                newBackgroundView.removeFromSuperview()
                downloadTask.removeAllObservers()
            }
        }
        
        UserDefaults.standard.set("\(destinationUrl.path)", forKey: "soundPath")
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
