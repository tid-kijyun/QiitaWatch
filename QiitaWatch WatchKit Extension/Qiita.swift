//
//  Qiita.swift
//  QiitaWatch
//
//  Created by tid on 2014/11/23.
//  Copyright (c) 2014年 tid. All rights reserved.
//
import Foundation

public class Qiita {
    struct API {
        static let URL = "https://qiita.com/api/v1"
    }
    
    enum StatusCode : Int {
        case OK                  = 200
        case Created             = 201
        case NoContent           = 204
        case BadRequest          = 400
        case Unauthorized        = 401
        case Forbidden           = 403
        case NotFound            = 404
        case InternalServerError = 500
    }
    
    public typealias FailureHandler = ((response: NSURLResponse!, data: NSData!, error: NSError!) -> Void)
    
    public class func getToken(name: String, pass: String, success: ((token: String) -> Void)?, failure: FailureHandler? = nil) {
        let request = NSMutableURLRequest(URL: NSURL(string: "\(API.URL)/auth?url_name=\(name)&password=\(pass)")!)
        request.HTTPMethod = "POST"
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == StatusCode.OK.rawValue {
                    var jerror: NSError?
                    if let dic = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &jerror) as? NSDictionary {
                        if jerror == nil {
                            let token = dic["token"] as String
                            success?(token: token)
                            return
                        }
                    }
                }
            }
            
            failure?(response: response, data: data, error: error)
        }
    }
    
    public class func getTagItems(token: String?, tag: String, page: Int, parPage: Int, success: ((articles: [Article])->Void)?, failure: FailureHandler? = nil) {
        let request = NSMutableURLRequest(URL: NSURL(string: "\(API.URL)/tags/\(tag)/items?token=\(token!)")!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == StatusCode.OK.rawValue && error == nil {
                    var articles : [Article] = []
                    var jerror: NSError?
                    if let ary = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &jerror) as? NSArray {
                        if jerror == nil {
                            for item in ary {
                                if let dic = item as? NSDictionary {
                                    let uuid         = dic["uuid"] as String
                                    let title        = dic["title"] as String
                                    let author       = dic["user"]!["url_name"] as String
                                    let authorImgUrl = dic["user"]!["profile_image_url"] as String
                                    let isStock      = dic["stocked"] as? Bool ?? false
                                    
                                    let article = Article(
                                        uuid: uuid,
                                        title: title,
                                        author: author,
                                        authorImgUrl: authorImgUrl)
                                    article.isStock = isStock
                                    
                                    articles.append(article)
                                }
                            }
                            success?(articles: articles)
                            return
                        }
                    }
                }
            }
            failure?(response: response, data: data, error: error)
        }
    }

    public class func stock(token: String, itemId: String, stock: Bool, success: (() -> Void)?, failure: FailureHandler? = nil) {
        let request = NSMutableURLRequest(URL: NSURL(string: "\(API.URL)/items/\(itemId)/stock?token=\(token)")!)
        request.HTTPMethod = (stock) ? "DELETE" : "PUT"
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == StatusCode.NoContent.rawValue {
                    success?()
                    return
                }
            }
            failure?(response: response, data: data, error: error)
        }
    }
}

public class Article {
    var uuid: String
    var title: String
    var author: String
    var authorImgUrl: String
    var isStock: Bool = false
    
    init(uuid: String, title: String, author: String, authorImgUrl: String) {
        self.uuid = uuid
        self.title = title
        self.author = author
        self.authorImgUrl = authorImgUrl
    }
}

extension Article : Printable {
    public var description: String {
        return "uuid: \(self.uuid)" +
            "title: \(self.title)\n" +
            "author: \(self.author)\n" +
        "authorImgUrl: \(self.authorImgUrl)"
    }
}

