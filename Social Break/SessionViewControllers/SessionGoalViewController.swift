//
//  SessionGoalViewController.swift
//  Social Break
//
//  Created by Matthew Mech on 12/17/20.
//

import UIKit
import CoreData

class goalCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var FXView: UIVisualEffectView!
}

class SessionGoalViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var customGoal: UIButton!
    @IBOutlet weak var customGoalFX: UIVisualEffectView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIView!
    @IBOutlet weak var UICollectionView: UICollectionView!
    
    let reuseIdentifier = "goalCell"
    
    var cellImages = [UIImage]()
    var cellLabels = [String]()
    
    var selectedTime: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.string(forKey: "backgroundImage") ?? "BackgroundImage1" == "BackgroundImage1" {
            self.backgroundImageView?.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.250)
        } else {
            self.backgroundImageView?.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500)
        }
        
        let image1  = UIImage(named: "GoalWork")
        let image2  = UIImage(named: "GoalMeditate")
        let image3  = UIImage(named: "GoalTakeNap")
        let image4  = UIImage(named: "GoalReadBook")
        let image5  = UIImage(named: "GoalWorkout")
        let image6  = UIImage(named: "GoalRelax")
        let image7  = UIImage(named: "GoalChores")
        let image8  = UIImage(named: "GoalGoOutside")
        let image9  = UIImage(named: "GoalMusic")
        let image10  = UIImage(named: "GoalShop")
        let image11  = UIImage(named: "GoalShower")
        
        cellImages = [image1, image2, image3, image4, image5, image6, image7, image8, image9, image10, image11] as! [UIImage]
        cellLabels = ["Work", "Meditate", "Nap", "Read", "Workout", "Relax", "Chores", "Go Outside", "Listen to Music", "Shop", "Shower"]
        
        UICollectionView?.backgroundColor = .clear
        UICollectionView?.allowsMultipleSelection = false
        UICollectionView?.contentInsetAdjustmentBehavior = .always
        
        self.customGoal?.addTarget(self, action: #selector(setCustomGoal), for: .touchUpInside)
        self.closeButton?.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        self.backgroundImage?.image = UIImage(named: "\(UserDefaults.standard.string(forKey: "backgroundImage") ?? "BackgroundImage1")")
        self.backgroundImage?.contentMode = .scaleAspectFill
        
        self.customGoalFX?.layer.cornerRadius = 16
        self.customGoalFX?.layer.masksToBounds = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cellImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(reuseIdentifier)", for: indexPath) as! goalCollectionViewCell
        
        cell.imageView.image = self.cellImages[indexPath.item]
        cell.imageView.contentMode = .scaleAspectFit
        
        cell.label.text = self.cellLabels[indexPath.item]
        
        cell.FXView.layer.cornerRadius = 15
        cell.FXView.layer.masksToBounds = true
        
        cell.layer.cornerRadius = 15
        cell.layer.masksToBounds = true
        
        collectionView.delaysContentTouches = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sessionVC = self.storyboard?.instantiateViewController(withIdentifier: "sessionViewController") as! sessionViewController
        sessionVC.modalPresentationStyle = .fullScreen
        sessionVC.selectedTime = selectedTime
        sessionVC.goalString = String(self.cellLabels[indexPath.item])
        self.present(sessionVC, animated: false, completion: nil)
    }
    
    @objc func setCustomGoal() {
        let customVC = self.storyboard?.instantiateViewController(withIdentifier: "customGoalViewController") as! CustomGoalViewController
        customVC.modalPresentationStyle = .overCurrentContext
        customVC.selectedTime = selectedTime
        self.present(customVC, animated: false, completion: nil)
    }
    
    @objc func dismissView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundImage.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            
            self.backgroundImage.alpha = 0
            self.closeButton.alpha = 0
            self.UICollectionView.alpha = 0
        }) { (success: Bool) in
            let mainVC = MainPageViewController()
            mainVC.modalPresentationStyle = .fullScreen
            if #available(iOS 13.0, *) {
                mainVC.isModalInPresentation = true
            }
            self.present(mainVC, animated: false, completion: nil)
        }
    }
}

