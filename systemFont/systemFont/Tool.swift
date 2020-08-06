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
}
