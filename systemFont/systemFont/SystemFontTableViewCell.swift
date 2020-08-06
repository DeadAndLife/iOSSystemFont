//
//  SystemFontTableViewCell.swift
//  systemFont
//
//  Created by iOSzhang Inc on 20/8/5.
//  Copyright © 2020 iOSzhang Inc. All rights reserved.
//

import UIKit

class SystemFontTableViewCell: UITableViewCell {

    @IBOutlet weak var fontNameLabel: UILabel!
    @IBOutlet weak var showTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tapInit()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func tapInit() -> Void {
        let doubleTapGR = UITapGestureRecognizer.init(target: self, action: #selector(doubleTap(_:)))
        doubleTapGR.numberOfTapsRequired = 2
        
        fontNameLabel.addGestureRecognizer(doubleTapGR)
    }
    
    @objc func doubleTap(_ sender: UITapGestureRecognizer) -> Void {
        let pas = UIPasteboard.general
        pas.string = fontNameLabel.text
        
        Tool.showMessage("\(NSLocalizedString("已复制到粘贴板", comment: "copied to pasteboard"))")
    }
    
}
