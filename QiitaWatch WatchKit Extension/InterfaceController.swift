//
//  InterfaceController.swift
//  QiitaWatch WatchKit Extension
//
//  Created by tid on 2014/11/23.
//  Copyright (c) 2014年 tid. All rights reserved.
//
import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var headLineTable: WKInterfaceTable!
    
    let userName    = ""         // アカウントID
    let password    = ""         // パスワード
    let tag         = "WatchKit" // 記事タグ
    
    var accessToken = ""         // アクセストークン
    var articles: [Article] = []

    override init(context: AnyObject?) {
        // Initialize variables here.
        super.init(context: context)
        
        // Configure interface objects here.
        NSLog("%@ init", self)
        
        Qiita.getToken(userName, pass: password,
            success: { (token) -> Void in
                NSLog("Success : get AccessToken")
                self.accessToken = token
                self.reloadData()
            },
            failure: { (response, data, error) -> Void in
                NSLog("Fail : get AccessToken")
                self.reloadData()
            })
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        NSLog("%@ will activate", self)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        NSLog("%@ did deactivate", self)
        super.didDeactivate()
    }
    
    func loadTableData() {
        headLineTable.setNumberOfRows(self.articles.count, withRowType: "default")
        
        for (i, article) in enumerate(self.articles) {
            if var row = headLineTable.rowControllerAtIndex(i) as? HeadLineTableRow {
                row.article = article
            }
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        if var row = table.rowControllerAtIndex(rowIndex) as? HeadLineTableRow {
            Qiita.stock(accessToken, itemId: row.uuid, stock: row.isStock) {
                row.isStock = !row.isStock
            }
        }
    }

    func reloadData() {
        Qiita.getTagItems(accessToken, tag: tag, page: 1, parPage: 10) {
            (articles) in
                self.articles = articles
                self.loadTableData()
            }
    }
    
    @IBAction func menuItemTapped() {
        NSLog("menu item tapped")
        self.reloadData()
    }
}