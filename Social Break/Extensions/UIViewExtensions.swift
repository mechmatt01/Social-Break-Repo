//
//  UIViewExtensions.swift
//  Social Break
//
//  Created by Matthew Mech on 12/16/20.
//

import UIKit

extension UIView {
    
    func addAndActivateConstraints(constraints:[NSLayoutConstraint]) {
        NSLayoutConstraint.activate(constraints)
        self.addConstraints(constraints)
    }
    
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    func addLeadingTrailingTopBottomSizeConstraints(_ view: UIView) {
        if #available(iOS 11.0, *) {
            let leading = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 0)
            let trailing = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: 0)
            let top = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0)
            let bottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
            let constraints = [leading, trailing, top, bottom]
            NSLayoutConstraint.activate(constraints)
            addConstraints(constraints)
        } else {
            self.addConstraintsWithFormat(format: "H:|-0-[v0]-0-|", views: view)
            self.addConstraintsWithFormat(format: "V:|-0-[v0]-0-|", views: view)
        }
    }
    
    func animateView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0.5
        }) { (success) in
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 1.0
            } )
        }
    }

    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
    
    public func removeAllConstraints() {
        var _superview = self.superview

        while let superview = _superview {
            for constraint in superview.constraints {

                if let first = constraint.firstItem as? UIView, first == self {
                    superview.removeConstraint(constraint)
                }

                if let second = constraint.secondItem as? UIView, second == self {
                    superview.removeConstraint(constraint)
                }
            }

            _superview = superview.superview
        }

        self.removeConstraints(self.constraints)
        self.translatesAutoresizingMaskIntoConstraints = true
    }
}

extension UIApplication {
    var statusBarView: UIView? {
        if responds(to: Selector(("statusBar"))) {
            return value(forKey: "statusBar") as? UIView
        }
        return nil
    }
}
