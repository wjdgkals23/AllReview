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
import UIKit

class ViewModel: NSObject, WKNavigationDelegate {
    
    var userLoginSession = UserLoginSession.sharedInstance
    let request = OneLineReviewAPI.sharedInstance
    var backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)
    let disposeBag = DisposeBag()
    var urlMaker = OneLineReviewURL()
    var urlParserContext:((WKWebView, WKNavigationAction, (WKNavigationActionPolicy) -> Void) -> Void)?
    
    var mainViewRequestSubject:BehaviorSubject<URLRequest> = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
    var rankViewRequestSubject:BehaviorSubject<URLRequest> = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
    var myViewRequestSubject:BehaviorSubject<URLRequest> = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
    
    let goToNewViewControllerReviewSubject = PublishSubject<(String,[String:String])>()
    let goToMyContentDetailViewSubject = PublishSubject<Void>()
    
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
//                print(webView.title)
                if(webView.title == "마이페이지") { //memeerID 의 페이지
                    self.loadPageView(.contentDetailView, queryDict, (self.myViewRequestSubject))
                } else if (webView.title == "메인 신규리스트") {
                    self.loadPageView(.contentDetailView, queryDict, (self.mainViewRequestSubject))
                } else if (webView.title == "멤버 페이지") {
                    self.loadPageView(.contentDetailView, queryDict, (self.mainViewRequestSubject))
                }
                return
            }
            else if((url?.contains("app://WriteContent"))!) {
                handler(.allow)
                let index = url?.firstIndex(of: "?") ?? url?.endIndex
                let temp = String((url?[index!...])!)
                let queryDict = temp.parseQueryString()
                self.goToNewViewControllerReviewSubject.on(.next(("add", queryDict)))
                return
            }
            else if((url?.contains("app://ExternalBrowser"))!) {
                handler(.allow)
                let index = url?.firstIndex(of: "?") ?? url?.endIndex
                let temp = String((url?[index!...])!)
                let queryDict = temp.parseQueryString()
    
                let externalUrl = URL(string: ((queryDict["url"])!.decodeUrl())!)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(externalUrl!)
                } else {
                    // Fallback on earlier versions
                    return
                }
            }
            else if((url?.contains("app://SearchMovie"))!) {
                handler(.allow)
                self.goToNewViewControllerReviewSubject.on(.next(("search",["":""])))
            }
            else if((url?.contains("app://MemberContents"))!) {
                handler(.allow)
                let index = url?.firstIndex(of: "?") ?? url?.endIndex
                let temp = String((url?[index!...])!)
                let queryDict = temp.parseQueryString()
                self.loadPageView(.showMembersContents, queryDict, (self.mainViewRequestSubject))
            }
            else if((url?.contains("app://MyContents"))!) {
                handler(.allow)
                let index = url?.firstIndex(of: "?") ?? url?.endIndex
                let temp = String((url?[index!...])!)
                let queryDict = temp.parseQueryString()
                self.loadPageView(.mainMyView, queryDict, (self.myViewRequestSubject))
                self.goToMyContentDetailViewSubject.onNext(())
            }
            else {
                handler(.cancel)
                return
            }
        }
    }
    
    func loadPageView(_ urlTarget:OneLineReview, _ param:[String:String], _ target: BehaviorSubject<URLRequest>) {
        self.urlMaker.rxMakeURLRequestObservable(urlTarget, param).bind(to: target).disposed(by: disposeBag)
    }
    
}
