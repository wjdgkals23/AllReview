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

class MainViewModel: NSObject {
    
    private var userLoginSession = UserLoginSession.sharedInstance
    private let request = OneLineReviewAPI.sharedInstance
    private let disposeBag = DisposeBag()
    private let backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)
    public var urlMaker = OneLineReviewURL()
    
    let mainViewRequestSubject:BehaviorSubject<URLRequest>
    let rankViewRequestSubject:BehaviorSubject<URLRequest>
    let myViewRequestSubject:BehaviorSubject<URLRequest>
    
    override init() {
        mainViewRequestSubject = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        rankViewRequestSubject = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        myViewRequestSubject = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        
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

extension MainViewModel: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let request = navigationAction.request
        let url = request.url?.absoluteString
        
        if((url?.contains("https://www.teammiracle.be"))!) {
            decisionHandler(.allow)
            return
        }
        else if((url?.contains("app://contentDetail"))!) {
            decisionHandler(.allow)
            let index = url?.firstIndex(of: "?") ?? url?.endIndex
            let temp = String((url?[index!...])!)
            let queryDict = temp.parseQueryString()
            self.urlMaker.rxMakeURLRequestObservable(.contentDetailView, queryDict).bind(to: mainViewRequestSubject).disposed(by: disposeBag)
            return
        } else {
            decisionHandler(.cancel)
            return
        }
    }
}
