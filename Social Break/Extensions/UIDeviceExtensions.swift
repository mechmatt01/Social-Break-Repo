//
//  UIDeviceExtensions.swift
//  Social Break
//
//  Created by Matthew Mech on 12/17/20.
//

import UIKit

extension UIDevice {
    
    enum ScreenType: String {
        case iPhones_SE = "iPhone SE"
        case iPhones_6_6s_7_8_SE2 = "iPhone 6, iPhone 6S, iPhone 7, iPhone 8 or iPhone SE2"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhones_X_XS_11Pro_12Mini = "iPhone X, iPhone XS, iPhone 11 Pro or iPhone 12 Mini"
        case iPhones_XR_11 = "iPhone XR or iPhone 11"
        case iPhones_XSMax_11ProMax = "iPhone XS Max or iPhone 11 Pro Max"
        case iPhones_12_12Pro = "iPhone 12 or iPhone 12 Pro"
        case iPhones_12ProMax = "iPhone 12 Pro Max"
        case unknown
    }
    
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 1136:
            return .iPhones_SE
        case 1334:
            return .iPhones_6_6s_7_8_SE2
        case 1792:
            return .iPhones_XR_11
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhones_X_XS_11Pro_12Mini
        case 2688:
            return .iPhones_XSMax_11ProMax
        case 2532:
            return .iPhones_12_12Pro
        case 2778:
            return .iPhones_12ProMax
        default:
            return .unknown
        }
    }
}
