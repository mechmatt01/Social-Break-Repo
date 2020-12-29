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
    
    private var storyboardIds : [String] = [StoryboardIds.Main.MainVC.rawValue,
                                            StoryboardIds.Main.StatsVC.rawValue,
                                            StoryboardIds.Main.SettingsVC.rawValue,
                                            StoryboardIds.Main.AboutVC.rawValue]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpPageViewController()
        self.setUpPageControl()
        self.setUpIntroViewControllers()
        let layer = self.getImage()
        layer.frame = self.view.frame
        self.view.insertSubview(layer, at: 0)
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
    
    /*
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed { return }
        DispatchQueue.main.async() {
            self.pageViewController.dataSource = nil
            self.pageViewController.dataSource = self
        }
    }
    */
    
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
        self.view.insertSubview(image, at: 0)
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
        //self.view.addConstraintsWithFormat(format: "H:[v0(38)]", views: menuIconButton)
        //self.view.addConstraintsWithFormat(format: "V:[v0(45)]", views: menuIconButton)
        self.view.addConstraintsWithFormat(format: "H:[v0(20)]", views: menuIconButton)
        self.view.addConstraintsWithFormat(format: "V:[v0(45)]", views: menuIconButton)
        let xConstraint = NSLayoutConstraint(item: menuIconButton, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 15)
        let yConstraint = NSLayoutConstraint(item: menuIconButton, attribute: .top, relatedBy: .equal, toItem: pageViewController.view, attribute: .top, multiplier: 1.0, constant: 44)
        
        self.view.addAndActivateConstraints(constraints: [xConstraint,yConstraint])
        menuIconButton.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
    }
    
    @objc private func showMenu() {
        let vc1 = Storyboards.main.instantiateViewController(withIdentifier: StoryboardIds.Main.AboutVC.rawValue) as! BasePageController
        self.present(vc1, animated: true, completion: nil)
        //self.pageViewController.setViewControllers([vc1], direction: .forward, animated: true, completion: nil)
        /*
        if let menuVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController {
            let baseIntroViewController: BasePageController = BasePageController()
            let index = baseIntroViewController.pageIndex
            
            menuVC.modalPresentationStyle = .overCurrentContext
            if index == 0 {
                menuVC.comingFrom = "mainVC"
            } else if index == 1 {
                menuVC.comingFrom = "statsVC"
            } else if index == 2 {
                menuVC.comingFrom = "settingsVC"
            } else if pageControl.currentPage == 3 {
                menuVC.comingFrom = "aboutVC"
            }
            self.present(menuVC, animated: false, completion: nil)
        }
         */
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
        case AboutVC = "AboutViewController"
    }
}

struct Storyboards {
    
    static var main : UIStoryboard {
        return UIStoryboard.init(name: "Main", bundle: nil)
    }
    
}
