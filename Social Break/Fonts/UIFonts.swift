//
//  UIFonts.swift
//  Social Break
//
//  Created by Matthew Mech on 12/12/20.
//

import UIKit

extension UIFont {
    
    // Lobster
    static func lobsterRegularFont(size : CGFloat) -> UIFont {
        return UIFont(name: "Lobster-Regular", size: size) ??
            UIFont.systemFont(ofSize: size)
    }
    
    // SF Pro
    static func SFProRoundedMediumFont(size : CGFloat) -> UIFont {
        return UIFont(name: "SFProRounded-Medium", size: size) ??
            UIFont.systemFont(ofSize: size)
    }
    
    static func SFProRoundedBoldFont(size : CGFloat) -> UIFont {
        return UIFont(name: "SFProRounded-Bold", size: size) ??
            UIFont.systemFont(ofSize: size)
    }
    
    static func SFProRoundedUltralightFont(size : CGFloat) -> UIFont {
        return UIFont(name: "SFProRounded-Ultralight", size: size) ??
            UIFont.systemFont(ofSize: size)
    }
}
