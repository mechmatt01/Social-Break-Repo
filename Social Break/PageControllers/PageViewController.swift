//
//  PageViewController.swift
//  Social Break
//
//  Created by Matthew Mech on 12/16/20.
//

import UIKit

class MainPageViewController: UIViewController, UIPageViewControllerDataSource {
    
    private var pageViewController : UIPageViewController!
    let pageControl = UIPageControl.appearance()
    let imageLayer = UIImageView()
    let bgView = UIView()
    
    private var storyboardIds : [String] = [StoryboardIds.Main.MainVC.rawValue,
                                            StoryboardIds.Main.StatsVC.rawValue,
                                            StoryboardIds.Main.SettingsVC.rawValue]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpPageViewController()
        self.setUpPageControl()
        self.setUpIntroViewControllers()
        imageLayer.frame = self.view.frame
        imageLayer.image = UIImage(named: "\(UserDefaults.standard.string(forKey: "backgroundImage") ?? "BackgroundImage1")")
        imageLayer.contentMode = .scaleAspectFill
        bgView.frame = self.view.frame
        if UserDefaults.standard.string(forKey: "backgroundImage") ?? "BackgroundImage1" == "BackgroundImage1" {
            bgView.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.250)
        } else {
            bgView.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500)
        }
        self.view.insertSubview(imageLayer, at: 0)
        self.view.insertSubview(bgView, aboveSubview: imageLayer)
        self.addMenuButton()
    }
    
    private func setUpPageViewController() {
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: UIPageViewController.NavigationOrientation.vertical, options: nil)
        self.pageViewController.dataSource = self
        self.addChild(pageViewController)
        self.view.addSubview(pageViewController.view)
        self.pageViewController.didMove(toParent: self)
        self.view.addConstraintsWithFormat(format: "H:|-0-[v0]-0-|", views: pageViewController.view)
        self.view.addConstraintsWithFormat(format: "V:|-0-[v0]-0-|", views: pageViewController.view)
    }
    
    func reloadPageController() {
        DispatchQueue.main.async() {
            self.pageViewController?.dataSource = nil
            self.pageViewController?.dataSource = self
        }
    }
    
    private func setUpPageControl() {
        pageControl.isHidden = true
    }
    
    private func getImage() -> UIImageView {
        let image: UIImageView = UIImageView()
        image.image = UIImage(named: "\(UserDefaults.standard.string(forKey: "backgroundImage") ?? "BackgroundImage1")")
        image.contentMode = .scaleAspectFill
        return image
    }
    
    private func getUIView() -> UIView {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .white
        self.view.insertSubview(backgroundView, at: 0)
        return backgroundView
    }
    
    private func setUpIntroViewControllers() {
        let vc1 = Storyboards.main.instantiateViewController(withIdentifier: StoryboardIds.Main.MainVC.rawValue) as! BasePageController
        self.pageViewController.setViewControllers([vc1], direction: .forward, animated: true, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let baseIntroViewController: BasePageController = viewController as! BasePageController
        var index = baseIntroViewController.pageIndex
        if (index == NSNotFound) {
            return nil
        }
        index += 1
        if (index == self.storyboardIds.count) {
            return nil
        }
        return self.getViewControllerAt(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let baseIntroViewController: BasePageController = viewController as! BasePageController
        var index = baseIntroViewController.pageIndex
        if ((index == 0) || (index == NSNotFound)) {
            return nil
        }
        index -= 1
        return self.getViewControllerAt(index: index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return storyboardIds.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    private func addMenuButton() {
        let menuIconButton = UIButton()
        menuIconButton.setImage(UIImage(named: "MenuIcon"), for: .normal)
        self.view.addSubview(menuIconButton)
        self.view.addConstraintsWithFormat(format: "H:[v0(20)]", views: menuIconButton)
        self.view.addConstraintsWithFormat(format: "V:[v0(45)]", views: menuIconButton)
        let xConstraint = NSLayoutConstraint(item: menuIconButton, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 15)
        let yConstraint = NSLayoutConstraint(item: menuIconButton, attribute: .top, relatedBy: .equal, toItem: pageViewController.view, attribute: .top, multiplier: 1.0, constant: 44)
        
        self.view.addAndActivateConstraints(constraints: [xConstraint,yConstraint])
        menuIconButton.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
    }

    @objc private func showMenu() {
        let vc1 = Storyboards.main.instantiateViewController(withIdentifier: "AboutViewController") as! BasePageController
        self.present(vc1, animated: true, completion: nil)
    }
    
    private func getViewControllerAt(index: NSInteger) -> BasePageController {
        let controller = Storyboards.main.instantiateViewController(withIdentifier: storyboardIds[index]) as! BasePageController
        controller.pageIndex = index
        return controller
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        view.removeFromSuperview()
    }
}

struct StoryboardIds {
    
    enum Main: String {
        case MainVC = "MainViewController"
        case StatsVC = "StatsViewController"
        case SettingsVC = "SettingsViewController"
    }
}

struct Storyboards {
    
    static var main : UIStoryboard {
        return UIStoryboard.init(name: "Main", bundle: nil)
    }
    
}
