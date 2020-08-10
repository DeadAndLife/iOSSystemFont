//
//  TableViewController.swift
//  systemFont
//
//  Created by iOSzhang Inc on 20/8/10.
//  Copyright © 2020 iOSzhang Inc. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UISearchBarDelegate {
    
    var allFontsModel : AllFontsModel!
    var systemFontsArray = [FontModel]()
    var importedFontsArray = [FontModel]()
    var searchSourceArray = [FontModel]()
    var searchResultArray : [FontModel] = [FontModel]()
    
    var nowColor: UIColor = UIColor.init(hexCode: "#999999", alpha: 1)
    //        UIColor.init(white: 0.6, alpha: 1)
    var nowFontSize: CGFloat = 16
    var nowText: String = "Default text. Double click the title to copy the font name\n默认文字,双击标题即可复制字体名称\n1234567890😊"
    
    let searchBar : UISearchBar = UISearchBar.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewInit()
        dataInit()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchResultArray.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        searchBar.frame = CGRect.init(x: 0, y: 0, width: mainScreenSize.width, height: 56)
        searchBar.placeholder = "请输入搜索的字体名"
        searchBar.delegate = self
        
        return searchBar
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fontCell", for: indexPath) as! SystemFontTableViewCell
        
        cell.selectionStyle = .none
        
        let fontModel = searchResultArray[indexPath.row]
            let nowFont = UIFont.init(name: fontModel.fontName, size: nowFontSize)
        cell.fontNameLabel.text = "\(indexPath.row+1) \(String(describing: fontModel.fontName)) \n  \(String(describing: fontModel.fontDisplayName))"
        cell.fontNameLabel.font = nowFont
        cell.showTextLabel.font = nowFont
        
        cell.showTextLabel.text = nowText
        cell.fontNameLabel.textColor = nowColor
        cell.showTextLabel.textColor = nowColor

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func viewInit() -> Void {
        title = "搜索"

        tableView.register(UINib(nibName: "SystemFontTableViewCell", bundle:  nil), forCellReuseIdentifier: "fontCell")
    }
    
    func dataInit() -> Void {
//        allFontsModel.systemFontsInit()
//        allFontsModel.importedFontsInit()
        systemFontsRefreshed(Notification.init(name: Notification_SystemFontFinished))
        importedFontsRefreshed(Notification.init(name: Notification_ImportedFontFinished))
        
        NotificationCenter.default.addObserver(self, selector: #selector(systemFontsRefreshed(_:)), name: Notification_SystemFontFinished, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(importedFontsRefreshed(_:)), name: Notification_ImportedFontFinished, object: nil)
    }
    
    //MARK: - NotificationCenter
    @objc func systemFontsRefreshed(_ notifiction: Notification) -> Void {
        systemFontsArray.removeAll()
        for familyFontModel in allFontsModel.systemFonts {
            for fontModel in familyFontModel.fontModels {
                systemFontsArray.append(fontModel)
            }
        }
        searchSourceArray = systemFontsArray+importedFontsArray
        
        search()
    }
    
    @objc func importedFontsRefreshed(_ notifiction: Notification) -> Void {
        self.importedFontsArray.removeAll()
        for familyFontModel in allFontsModel.importedFonts {
            for fontModel in familyFontModel.fontModels {
                importedFontsArray.append(fontModel)
            }
        }
        searchSourceArray = systemFontsArray+importedFontsArray
        
        search()
    }
    
    //MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        search()
    }
    
    func search() -> Void {
        if !searchBar.text!.isEmpty {
            searchResultArray.removeAll()
            let searchString = searchBar.text!
            
            for fontModel in searchSourceArray {
                let predicate = NSPredicate.init(format: "SELF CONTAINS[cd] '\(searchString)'")
                
                if predicate.evaluate(with: fontModel.fontName) ||
                   predicate.evaluate(with: fontModel.fontFamilyName) ||
                   predicate.evaluate(with: fontModel.fontDisplayName) {
                    searchResultArray.append(fontModel)
                }
            }
            
            tableView.reloadData()
        }
    }
}
