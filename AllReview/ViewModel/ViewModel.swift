//
//  ViewParent.swift
//  AllReview
//
//  Created by 정하민 on 2019/12/12.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import WebKit

class ViewModel: NSObject {
    
    var userLoginSession = UserLoginSession.sharedInstance
    let request = OneLineReviewAPI.sharedInstance
    var backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)
    let disposeBag = DisposeBag()
    var urlMaker = OneLineReviewURL()
    var urlParserContext:((WKWebView, WKNavigationAction, (WKNavigationActionPolicy) -> Void) -> Void)?
    
    var mainViewRequestSubject:BehaviorSubject<URLRequest> = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
    var rankViewRequestSubject:BehaviorSubject<URLRequest> = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
    var myViewRequestSubject:BehaviorSubject<URLRequest> = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
    
    let goToAddNewReviewSubject = PublishSubject<(String,[String:String])>()
    
    override init() {
        super.init()
        self.urlParserContext = {(webView: WKWebView, response: WKNavigationAction, handler: (WKNavigationActionPolicy) -> Void) -> Void in
            
            let url = response.request.url?.absoluteString
            
            if((url?.contains("https://www.teammiracle.be"))!) {
                handler(.allow)
                return
            }
            else if((url?.contains("app://ContentDetail"))!) {
                handler(.allow)
                let index = url?.firstIndex(of: "?") ?? url?.endIndex
                let temp = String((url?[index!...])!)
                let queryDict = temp.parseQueryString()
                if(webView.title == "마이페이지") {
                    self.loadPageView(.contentDetailView, queryDict, (self.myViewRequestSubject))
                } else if (webView.title == "메인 신규리스트") {
                    self.loadPageView(.contentDetailView, queryDict, (self.mainViewRequestSubject))
                }
                return
            }
            else if((url?.contains("app://writeContent"))!) {
                handler(.allow)
                let index = url?.firstIndex(of: "?") ?? url?.endIndex
                let temp = String((url?[index!...])!)
                let queryDict = temp.parseQueryString()
                self.goToAddNewReviewSubject.on(.next(("add", queryDict)))
                return
            }
            else {
                handler(.cancel)
                return
            }
        }
    }
    
    func loadPageView(_ urlTarget:OneLineReview, _ param:[String:String], _ target: BehaviorSubject<URLRequest>) {
        self.urlMaker.rxMakeURLRequestObservable(.contentDetailView, param).bind(to: target).disposed(by: disposeBag)
    }
    
}
