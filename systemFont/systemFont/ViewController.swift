//
//  ViewController.swift
//  systemFont
//
//  Created by iOSzhang Inc on 20/8/5.
//  Copyright © 2020 iOSzhang Inc. All rights reserved.
//

import UIKit

let mainScreenSize = UIScreen.main.bounds.size

class ViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showTextView: UITextView!
    @IBOutlet weak var showTextColor: UIButton!
    @IBOutlet weak var showTextFontSize: UITextField!
    
    @IBOutlet weak var pickerSuperView: UIView!
    
    @IBOutlet weak var selectedTextColorButton: UIButton!

    @IBOutlet weak var pickerViewTop: NSLayoutConstraint!
    
    var allFonts: NSMutableArray = NSMutableArray.init()
    let defaultString = "默认文字,双击标题即可复制字体名称"
    
    var nowColor: UIColor = UIColor.init(hexCode: "#999999", alpha: 1)
//        UIColor.init(white: 0.6, alpha: 1)
    var nowFontSize: CGFloat = 16
    var redPoint: Int = 99
    var greenPoint: Int = 99
    var bluePoint: Int = 99

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataInit()
        view.backgroundColor = UIColor.init(hexCode: "#fcfcfc", alpha: 1)
        
//            UIColor.init(white: 0.8, alpha: 1)
//        viewInit()
        tableView.register(UINib(nibName: "SystemFontTableViewCell", bundle: nil), forCellReuseIdentifier: "fontCell")
        
        // Do any additional setup after loading the view.
    }
    
    func dataInit() -> Void {
        DispatchQueue.global().async {
            for familyName: String in UIFont.familyNames {
                for fontName: String in UIFont.fontNames(forFamilyName: familyName) {
                    self.allFonts.add(fontName)
                }
            }
            DispatchQueue.main.async {
                if self.isViewLoaded {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        nowFontSize = CGFloat(Float(textField.text!) ?? 16)
        if self.isViewLoaded {
            self.tableView.reloadData()
        }
    }
    
    //MARK: - UITextViewDelegate
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.isViewLoaded {
            self.tableView.reloadData()
        }
    }
 
    //MARK: - scroll
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.showTextView.resignFirstResponder()
        self.showTextFontSize.resignFirstResponder()
    }
    
    //MARK: - UITableViewDelegate
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFonts.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fontCell", for: indexPath) as! SystemFontTableViewCell
        
        cell.selectionStyle = .none

        let fontString = allFonts[indexPath.row] as! String
        let nowFont = UIFont.init(name: fontString, size: nowFontSize)
        let cff = CTFontCopyDisplayName(nowFont! as CTFont)
        cell.fontNameLabel.text = "\(indexPath.row+1) \(fontString) \n  \(cff as String)"
        cell.showTextLabel.text = showTextView.text
        cell.fontNameLabel.textColor = nowColor
        cell.showTextLabel.textColor = nowColor
        cell.fontNameLabel.font = nowFont
        cell.showTextLabel.font = nowFont

        return cell
    }
    
    //MARK: - UIPickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 256
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            redPoint = row
            break
        case 1:
            greenPoint = row
            break
        case 2:
            bluePoint = row
            break
        default: break
        }
        
        selectedTextColorButton.setTitleColor(UIColor.init(red: CGFloat(redPoint)/255.0, green: CGFloat(greenPoint)/255.0, blue: CGFloat(bluePoint)/255.0, alpha: 1), for: .normal)
    }
    
    @IBAction func showTextColorClick(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.pickerViewTop.constant = -self.pickerSuperView.bounds.height
        }
    }
    
    @IBAction func selectedTextColorClick(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, animations: {
            self.pickerViewTop.constant = 0
        }) { (finished) in
            if finished {
                self.nowColor = UIColor.init(red: CGFloat(self.redPoint)/255.0, green: CGFloat(self.greenPoint)/255.0, blue: CGFloat(self.bluePoint)/255.0, alpha: 1)
                
                self.showTextColor.setTitle(self.nowColor.toHEXColorString(), for: .normal)
                self.showTextColor.setTitleColor(self.nowColor, for: .normal)
                if self.isViewLoaded {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
}

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

