//
//  BasePageController.swift
//  Social Break
//
//  Created by Matthew Mech on 12/16/20.
//

import UIKit

class BasePageController: UIViewController {
    
    var previousBackgroundImage = ""
    
    var bgView : UIView {
        return UIView()
    }
    
    var pageIndex : Int = 0
    let image: UIImageView = UIImageView()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if pageIndex == 2 && UserDefaults.standard.string(forKey: "backgroundImage") ?? "BackgroundImage1" != self.previousBackgroundImage {
            image.image = UIImage(named: "\(UserDefaults.standard.string(forKey: "backgroundImage") ?? "BackgroundImage1")")
            if UserDefaults.standard.string(forKey: "backgroundImage") ?? "BackgroundImage1" == "BackgroundImage1" {
                bgView.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.250)
            } else {
                bgView.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addImage()
    }
    
    private func addImage() {
        image.image = UIImage(named: "\(UserDefaults.standard.string(forKey: "backgroundImage") ?? "BackgroundImage1")")
        self.previousBackgroundImage = UserDefaults.standard.string(forKey: "backgroundImage") ?? "BackgroundImage1"
        image.contentMode = .scaleAspectFill
        if UserDefaults.standard.string(forKey: "backgroundImage") ?? "BackgroundImage1" == "BackgroundImage1" {
            bgView.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.250)
        } else {
            bgView.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500)
        }
        bgView.insertSubview(image, at: 0)
    }
}
