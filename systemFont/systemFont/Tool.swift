//
//  Tool.swift
//  systemFont
//
//  Created by iOSzhang Inc on 20/8/6.
//  Copyright © 2020 iOSzhang Inc. All rights reserved.
//

import UIKit

class Tool: NSObject {
    class func showMessage(_ message: String) {
        let window = UIApplication.shared.keyWindow
        let showView = UIView.init()
        showView.backgroundColor = .black
        showView.alpha = 1.0
        showView.layer.cornerRadius = 5.0
        window?.addSubview(showView)
        window?.bringSubviewToFront(showView)
        
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        label.backgroundColor = .clear
        label.sizeToFit()
        
        showView.addSubview(label)
        
        label.frame = CGRect.init(x: 5, y: 5, width: label.bounds.width, height: label.bounds.height)
        showView.frame = CGRect.init(x: (window!.bounds.width-label.bounds.width-10)/2, y: (window!.bounds.height-label.bounds.height-10)/2, width: label.bounds.width+10, height: label.bounds.height+10)
        
        UIView.animate(withDuration: 2, animations: {
            showView.alpha = 0
        }) { (finished) in
            showView.removeFromSuperview()
        }
    }
    
    class func copyInboxItemToDocumentFontsDirectory() -> Bool {
        let inboxURLString = String.applicationInboxDoucmentsDirectory()
        let copyToDoucURLString = String.applicationFontsDoucmentsDirectory()
        let inboxURL = URL.init(string: "file://"+inboxURLString)!
        let copyToDoucURL = URL.init(string: "file://"+copyToDoucURLString)!
        
        for fileName in FileManager.default.subpaths(atPath: inboxURLString) ?? [String]() {
            let url = inboxURL.appendingPathComponent(fileName, isDirectory: true)
            
            var copyToURL = copyToDoucURL.appendingPathComponent(fileName, isDirectory: false)
            if FileManager.default.fileExists(atPath: copyToURL.path) {
                var duplicateURL = copyToURL
                copyToURL = copyToURL.deletingPathExtension()
                //没有后缀的文件名
                let fileNameWithoutExtension = copyToURL.lastPathComponent
                //文件后缀
                let fileExtension = url.pathExtension;
                
                var i = 1
                while FileManager.default.fileExists(atPath: duplicateURL.pathExtension) {
                    //判断是否存在，存在就重新命名
                    copyToURL = copyToURL.deletingLastPathComponent()
                    copyToURL = copyToURL.appendingPathComponent("\(fileNameWithoutExtension)-\(i)")
                    copyToURL = copyToURL.appendingPathExtension(fileExtension)
                    duplicateURL = copyToURL;
                    i += 1;
                }
            }
            
            //把系统传过来的url对应的文件 移动到 本地app中
            print("move \(url) to \(copyToURL)")
            do {
                try FileManager.default.moveItem(at: url, to: copyToURL)
                
                var info = Bundle.main.infoDictionary
                var fonts:[String] = info?["UIAppFonts"] as! [String]
                if fonts.isEmpty {
                    fonts = [String]()
                }
                fonts.append("\(fileName)")
                info?.updateValue(fonts, forKey: "UIAppFonts")
                
                AllFontsModel.sharedInstance.importedFontsInit()
            } catch {
                Tool.showMessage("转存错误\n\(error.localizedDescription)")
                return false;
            }
            
        }
        return true;
    }
}
