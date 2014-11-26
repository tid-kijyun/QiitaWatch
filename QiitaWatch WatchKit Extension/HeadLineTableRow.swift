//
//  HeadLineTableRow.swift
//  QiitaWatch
//
//  Created by tid on 2014/11/23.
//  Copyright (c) 2014年 tid. All rights reserved.
//

import WatchKit

class HeadLineTableRow: NSObject {
    @IBOutlet weak var icon: WKInterfaceImage!
    @IBOutlet weak var headline: WKInterfaceLabel!
    @IBOutlet weak var author: WKInterfaceLabel!
    @IBOutlet weak var stock: WKInterfaceLabel!
    
    var uuid: String = ""
    
    var isStock : Bool = false {
        didSet {
            stock.setAlpha((isStock) ? 1.0 : 0.2)
        }
    }
    
    var article : Article? = nil {
        didSet {
            if let art = article {
                self.uuid = art.uuid
                self.headline.setText(art.title)
                self.author.setText(art.author)
                self.isStock = art.isStock
                
                let url = NSURL(string: art.authorImgUrl)
                let request = NSURLRequest(URL:url!)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) in
                    let image = UIImage(data: data)
                    self.icon.setImage(image)
                }
            }
        }
    }
}
