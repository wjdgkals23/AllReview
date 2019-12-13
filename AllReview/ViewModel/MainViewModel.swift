//
//  MainViewModel.swift
//  AllReview
//
//  Created by 정하민 on 2019/10/31.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import WebKit

class MainViewModel: ViewModel{
    
    var mainViewRequestSubject:BehaviorSubject<URLRequest>!
    var rankViewRequestSubject:BehaviorSubject<URLRequest>!
    var myViewRequestSubject:BehaviorSubject<URLRequest>!
    var urlParserContext:((WKWebView, WKNavigationAction, (WKNavigationActionPolicy) -> Void) -> Void)!
    
    override init() {
        super.init()
        self.mainViewRequestSubject = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        self.rankViewRequestSubject = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        self.myViewRequestSubject = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        
        self.urlParserContext = {(webView: WKWebView, response: WKNavigationAction, handler: (WKNavigationActionPolicy) -> Void) -> Void in
            
            let url = response.request.url?.absoluteString

            if((url?.contains("https://www.teammiracle.be"))!) {
                handler(.allow)
                return
            }
            else if((url?.contains("app://contentDetail"))!) {
                handler(.allow)
                let index = url?.firstIndex(of: "?") ?? url?.endIndex
                let temp = String((url?[index!...])!)
                let queryDict = temp.parseQueryString()
                if(webView.title == "마이페이지") {
                    self.loadPageView(.contentDetailView, queryDict, (self.myViewRequestSubject)!)
                } else if (webView.title == "메인 신규리스트") {
                    self.loadPageView(.contentDetailView, queryDict, (self.mainViewRequestSubject)!)
                }
                return
            }
            else {
                handler(.cancel)
                return
            }
        }
        
    }
    
    public func loginDataBindFirstPage(_ urlTarget:OneLineReview, _ subject:BehaviorSubject<URLRequest>) {
        userLoginSession.getLoginData()?.flatMap({ [weak self] data -> Observable<URLRequest> in
            let userData = ["memberId":data.data._id]
            let req = (self?.urlMaker.rxMakeURLRequestObservable(urlTarget, userData))!
            return req
        }).bind(to: subject)
            .disposed(by: disposeBag)
    }
    
}

extension MainViewModel: WKNavigationDelegate {
    
}
