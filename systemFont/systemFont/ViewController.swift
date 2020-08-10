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
    
//    var allFonts: NSMutableArray = NSMutableArray.init()
    var allFonts: AllFontsModel = AllFontsModel.sharedInstance
    
    let defaultString = "Default text. Double click the title to copy the font name\n默认文字,双击标题即可复制字体名称\n1234567890😊"
    
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
        allFonts.systemFontsInit()
        allFonts.importedFontsInit()
        
        NotificationCenter.default.addObserver(self, selector: #selector(systemFontsRefreshed(_:)), name: Notification_SystemFontFinished, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(importedFontsRefreshed(_:)), name: Notification_ImportedFontFinished, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushSearch" {
            let controller = segue.destination as! TableViewController
            controller.allFontsModel = self.allFonts
            controller.nowFontSize = self.nowFontSize
            controller.nowColor = self.nowColor
            controller.nowText = showTextView.text
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - NotificationCenter
    @objc func systemFontsRefreshed(_ notifiction: Notification) -> Void {
        self.tableView.reloadData()
    }
    
    @objc func importedFontsRefreshed(_ notifiction: Notification) -> Void {
        self.tableView.reloadData()
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
        return 2+allFonts.systemFonts.count+allFonts.importedFonts.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else if section <= allFonts.systemFonts.count {
            let index = (section-1)%allFonts.systemFonts.count
            let fontFamilyModel = allFonts.systemFonts[index]
            return fontFamilyModel.fontModels.count
        } else if section == allFonts.systemFonts.count+1 {
            return 0
        } else {
            let index = (section-2-allFonts.systemFonts.count)%allFonts.importedFonts.count
            let fontFamilyModel = allFonts.importedFonts[index]
            return fontFamilyModel.fontModels.count
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 0 {
//            return "系统自带字体"
//        } else if section <= allFonts.systemFonts.count {
//            let index = (section-1)%allFonts.systemFonts.count
//            let fontFamilyModel = allFonts.systemFonts.object(at: index) as! FontFamilyModel
//            return fontFamilyModel.fontFamily
//        } else if section == allFonts.systemFonts.count+1 {
//            return "导入字体"
//        } else {
//            let index = (section-2-allFonts.systemFonts.count)%allFonts.importedFonts.count
//            let fontFamilyModel = allFonts.importedFonts.object(at: index) as! FontFamilyModel
//            return fontFamilyModel.fontFamily
//        }
//        return ""
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init()
        headerView.backgroundColor = UIColor.init(hexCode: "#f5f5f5", alpha: 1)
        let titleLabel = UILabel.init()
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0
        headerView.addSubview(titleLabel)
        
        if section == 0 {
            titleLabel.text = "系统自带字体"
            titleLabel.font = UIFont.systemFont(ofSize: nowFontSize+4)
        } else if section <= allFonts.systemFonts.count {
            let index = (section-1)%allFonts.systemFonts.count
            let fontFamilyModel = allFonts.systemFonts[index]
            titleLabel.text = fontFamilyModel.fontFamily
            
            titleLabel.font = UIFont.systemFont(ofSize: nowFontSize+2)
        } else if section == allFonts.systemFonts.count+1 {
            titleLabel.text = "导入字体"
            titleLabel.font = UIFont.systemFont(ofSize: nowFontSize+4)
        } else {
            let index = (section-2-allFonts.systemFonts.count)%allFonts.importedFonts.count
            let fontFamilyModel = allFonts.importedFonts[index]
            titleLabel.text = fontFamilyModel.fontFamily
            
            titleLabel.font = UIFont.systemFont(ofSize: nowFontSize+2)
        }
        let titleSize = titleLabel.sizeThatFits(CGSize.init(width: mainScreenSize.width-15.0-15.0, height: CGFloat(MAXFLOAT)))
        titleLabel.frame = CGRect.init(x: 15, y: 2, width: titleSize.width, height: titleSize.height+4)
        
        titleLabel.sizeToFit()
        return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fontCell", for: indexPath) as! SystemFontTableViewCell
        
        cell.selectionStyle = .none
        
        if indexPath.section == 0 {
        } else if indexPath.section <= allFonts.systemFonts.count {
            let familyIndex = (indexPath.section-1)%allFonts.systemFonts.count
            let fontFamilyModel = allFonts.systemFonts[familyIndex]
            
            let fontIndex = indexPath.row%fontFamilyModel.fontModels.count
            let fontModel = fontFamilyModel.fontModels[fontIndex]
            let nowFont = UIFont.init(name: fontModel.fontName, size: nowFontSize)
            
            cell.fontNameLabel.text = "\(indexPath.row+1) \(String(describing: fontModel.fontName)) \n  \(String(describing: fontModel.fontDisplayName))"
            cell.fontNameLabel.font = nowFont
            cell.showTextLabel.font = nowFont
            
        } else if indexPath.section == allFonts.systemFonts.count+1 {
        } else {
            let familyIndex = (indexPath.section-2-allFonts.systemFonts.count)%allFonts.importedFonts.count
            let fontFamilyModel = allFonts.importedFonts[familyIndex]
            
            let fontIndex = indexPath.row%fontFamilyModel.fontModels.count
            let fontModel = fontFamilyModel.fontModels[fontIndex]
            let nowFont = UIFont.init(name: fontModel.fontName, size: nowFontSize)
            
            cell.fontNameLabel.text = "\(indexPath.row+1) \(String(describing: fontModel.fontName)) \n  \(String(describing: fontModel.fontDisplayName))"
            cell.fontNameLabel.font = nowFont
            cell.showTextLabel.font = nowFont
        }
        
        cell.showTextLabel.text = showTextView.text
        cell.fontNameLabel.textColor = nowColor
        cell.showTextLabel.textColor = nowColor

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
