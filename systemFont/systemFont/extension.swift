//
//  extension.swift
//  systemFont
//
//  Created by iOSzhang Inc on 20/8/10.
//  Copyright © 2020 iOSzhang Inc. All rights reserved.
//

import Foundation
import UIKit

let Notification_addNewFont = NSNotification.Name(rawValue: "addNewFont")

extension UIColor {
    convenience init(hexCode: String, alpha: Float) {
        var cString:String = hexCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
//        let scanner = Scanner(string: cString)
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
//            scanner.scanLocation = 1
//            scanner.locale = 1
        }
//        if (cString.hasPrefix("0x")) {
//            scanner.scanLocation = 2
////            scanner.locale = 2
//        }
        if ((cString.count) != 6) {
            self.init()
        } else {
            var rgbValue:UInt32 = 0
            Scanner(string: cString).scanHexInt32(&rgbValue)
            self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                      alpha: CGFloat(alpha))
        }
    }
    
    func toHEXColorString() -> String {
        var R: CGFloat = 0, G: CGFloat = 0, B: CGFloat = 0, A: CGFloat = 0
        self.getRed(&R, green: &G, blue: &B, alpha: &A)
        
        let rgb = (Int)(R*255.0)<<16 | (Int)(G*255.0)<<8 | (Int)(B*255.0)<<0
        
        return String.localizedStringWithFormat("#%06x", rgb)
    }
}

extension String {
    static func applicationInboxDoucmentsDirectory() -> String {
        var documentsDirectory : String = ""
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if paths.count > 0 {
            documentsDirectory = paths[0]
        }
        documentsDirectory += "/Inbox"
        if !FileManager.default.fileExists(atPath: documentsDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: documentsDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                Tool.showMessage("inbox文件夹创建失败")
            }
        }
        return documentsDirectory
    }
    
    static func applicationFontsDoucmentsDirectory() -> String {
        var documentsDirectory : String = ""
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if paths.count > 0 {
            documentsDirectory = paths[0]
        }
        documentsDirectory += "/fonts"
        if !FileManager.default.fileExists(atPath: documentsDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: documentsDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                Tool.showMessage("inbox文件夹创建失败")
            }
        }
        return documentsDirectory
    }
}

