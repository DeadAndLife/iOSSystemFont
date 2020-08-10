//
//  AllFontsModel.swift
//  systemFont
//
//  Created by iOSzhang Inc on 20/8/10.
//  Copyright © 2020 iOSzhang Inc. All rights reserved.
//

import UIKit

let Notification_SystemFontFinished = NSNotification.Name(rawValue: "systemFontFinished")
let Notification_ImportedFontFinished = NSNotification.Name(rawValue: "importedFontFinished")

class AllFontsModel: NSObject {
    static let sharedInstance : AllFontsModel = {
        let instance = AllFontsModel()
        NotificationCenter.default.addObserver(self, selector: #selector(addNewFont(_:)), name: Notification_addNewFont, object: nil)
        return instance
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var systemFonts: [FontFamilyModel] = [FontFamilyModel]()
    var importedFonts: [FontFamilyModel] = [FontFamilyModel]()
    
    func systemFontsInit() -> Void {
        self.systemFonts.removeAll()
        DispatchQueue.global().async {
            for familyName: String in UIFont.familyNames {
                let fontFamilyModel = FontFamilyModel.init()
                fontFamilyModel.fontFamily = familyName
                for fontName: String in UIFont.fontNames(forFamilyName: familyName) {
                    let fontModel = FontModel.init()
                    fontModel.fontSource = .system
                    fontModel.fontName = fontName
                    fontModel.fontFamilyName = familyName
                    let nowFont = UIFont.init(name: fontName, size: 1)
                    let cff = CTFontCopyDisplayName(nowFont! as CTFont)
                    fontModel.fontDisplayName = cff as String
                    
                    fontFamilyModel.fontModels.append(fontModel)
                }
                self.systemFonts.append(fontFamilyModel)
            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification_SystemFontFinished, object: nil, userInfo: ["model":self])
            }
        }
    }
    
    func importedFontsInit() -> Void {
        self.importedFonts.removeAll()
        DispatchQueue.global().async {
            let fontsDouc = String.applicationFontsDoucmentsDirectory()
            
            for fileName in FileManager.default.subpaths(atPath: fontsDouc) ?? [String]() {
                let fontData = NSData.init(contentsOfFile: fontsDouc+"/"+fileName)

                if fontData != nil {
//                     create font from loaded data and get it's postscript name
                    let fontDataProvider = CGDataProvider.init(data: fontData!)!
                    let loadedFont = CGFont.init(fontDataProvider)
                    let postScriptName = loadedFont?.postScriptName
                    
                    if postScriptName == nil {
                        return
                    }
                    
                    var error : Unmanaged<CFError>!
                    let canLoad = CTFontManagerRegisterGraphicsFont(loadedFont!, &error)
                    
                    if canLoad == false {
                        Tool.showMessage("不能加载字体\(fileName)")
                        return
                    }
                    
                    let ctfont = CTFontCreateWithName(postScriptName!, 1, nil)
                    
                    let fontModel = FontModel.init()
                    fontModel.fontSource = .imported
                    fontModel.fontName = postScriptName! as String
                    fontModel.fontFamilyName = CTFontCopyFamilyName(ctfont) as String
//                        CTFontCopyFamilyName(loadedFont! as! CTFont) as String
                    let cff = CTFontCopyDisplayName(ctfont)
//                        CTFontCopyDisplayName(loadedFont! as! CTFont)
                    fontModel.fontDisplayName = cff as String
                    
                    let predicate = NSPredicate.init(format: "SELF LIKE '\(fontModel.fontFamilyName)'")
                    
                    var hasFamily = false
                    
                    for familyModel in self.importedFonts {
                        if hasFamily == false && predicate.evaluate(with: familyModel.fontFamily) {
                            familyModel.fontModels.append(fontModel)
                            hasFamily = true
                        }
                    }
                    if hasFamily == false {
                        let familyModel = FontFamilyModel.init()
                        familyModel.fontFamily = fontModel.fontFamilyName
                        familyModel.fontModels.append(fontModel)
                        
                        self.importedFonts.append(familyModel)
                    }
                }
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification_ImportedFontFinished, object: nil, userInfo: ["model":self])
            }
        }
    }
    
    func index(_ fontModel: FontModel, source: FontSource) -> IndexPath {
        switch source {
        case .imported:
            for familyModel in self.importedFonts {
                
                if familyModel.fontFamily == fontModel.fontFamilyName {
                    
                    for thisFontModel in familyModel.fontModels {
                        if thisFontModel.fontName == fontModel.fontName {
                            let section = self.importedFonts.firstIndex(of: familyModel) ?? 0
                            let row = familyModel.fontModels.firstIndex(of: thisFontModel) ?? 0
                            
                            return IndexPath.init(row: row, section: section)
                        }
                    }
                    
                }
            }
            break
        default:
            for familyModel in self.systemFonts {
                
                if familyModel.fontFamily == fontModel.fontFamilyName {
                    
                    for thisFontModel in familyModel.fontModels {
                        if thisFontModel.fontName == fontModel.fontName {
                            let section = self.importedFonts.firstIndex(of: familyModel) ?? 0
                            let row = familyModel.fontModels.firstIndex(of: thisFontModel) ?? 0
                            
                            return IndexPath.init(row: row, section: section)
                        }
                    }
                    
                }
            }
            break
        }
        return IndexPath()
    }

    func fontModel(_ indexPath: IndexPath, source: FontSource) -> FontModel {
        switch source {
        case .imported:
            if indexPath.section >= self.importedFonts.count {
                return FontModel()
            }
            let familyModel = self.importedFonts[indexPath.section]
            if indexPath.row >= familyModel.fontModels.count {
                return FontModel()
            }
            return familyModel.fontModels[indexPath.row]
        default:
            if indexPath.section >= self.systemFonts.count {
                return FontModel()
            }
            let familyModel = self.systemFonts[indexPath.section]
            if indexPath.row >= familyModel.fontModels.count {
                return FontModel()
            }
            return familyModel.fontModels[indexPath.row]
        }
    }
    
    @objc func addNewFont(_ notifiction: Notification) -> Void {
        importedFontsInit()
    }
}

class FontFamilyModel: NSObject {
    var fontFamily : String! = ""
    var fontModels : [FontModel] = [FontModel]()
}

enum FontSource {
    case system     //系统
    case imported   //导入的
}

class FontModel: NSObject {
    
    /// 来源
    var fontSource : FontSource = .system
    
    /// 使用名称
    var fontName : String = ""
    
    /// 本地化后名称
    var fontDisplayName : String = ""
    
    /// 家族名称
    var fontFamilyName : String = ""
    
//    init(fontSource: FontSource, fontName: String) {
//        self.fontSource = fontSource
//        self.fontName = fontName
//    }
}
