//
//  File.swift
//  AllReview
//
//  Created by 정하민 on 2019/12/11.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import WebKit
import UIKit
import RxSwift


// Main Search!!

class TotalWebViewNaviParser: NSObject {
    
    static let sharedInstance = TotalWebViewNaviParser()
    var callViewRouter: PublishSubject<String>!
    var callWebViewRequestChange = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
    private var addNewReviewVCData: [String:String] = [String:String]()
    private var urlMaker: OneLineReviewURL!
    
    private var disposeBag = DisposeBag()
    
    override init() {
        callViewRouter = PublishSubject<String>()
        urlMaker = OneLineReviewURL()
    }
}

extension TotalWebViewNaviParser: WKUIDelegate, WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let request = navigationAction.request
        let url = request.url?.absoluteString
        if((url?.contains("https://www.teammiracle.be/"))!) {
            decisionHandler(.allow)
            return
        }
        else if((url?.contains("app://contentDetail"))!) {
            decisionHandler(.allow)
            let index = url?.firstIndex(of: "?") ?? url?.endIndex
            let temp = String((url?[index!...])!)
            let queryDict = temp.parseQueryString()
            self.urlMaker.rxMakeURLRequestObservable(.contentDetailView, queryDict).bind(to: callWebViewRequestChange).disposed(by: disposeBag)
            return
        }
        else if((url?.contains("app://writeContent"))!) {
            decisionHandler(.allow)
            let index = url?.firstIndex(of: "?") ?? url?.endIndex
            let temp = String((url?[index!...])!)
            let queryDict = temp.parseQueryString()
            addNewReviewVCData = queryDict
            callViewRouter.onNext(("addNew"))
            return
        }
        else {
            decisionHandler(.cancel)
            return
        }
    }
}
