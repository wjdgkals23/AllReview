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

class MainViewModel: NSObject, WKUIDelegate, WKNavigationDelegate {
    
    private var userLoginSession = UserLoginSession.sharedInstance
    private let request = OneLineReviewAPI.sharedInstance
    private let disposeBag = DisposeBag()
    private let backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)
    public var urlMaker = OneLineReviewURL()
    
    let mainViewButtonTapped:BehaviorSubject<URLRequest>
    let rankViewButtonTapped:BehaviorSubject<URLRequest>
    let myViewButtonTapped:BehaviorSubject<URLRequest>
    
    let mainViewButtonDriver:Driver<URLRequest>
    let rankViewButtonDriver:Driver<URLRequest>
    let myViewButtonDriver:Driver<URLRequest>
    
    override init() {
        mainViewButtonTapped = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        rankViewButtonTapped = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        myViewButtonTapped = BehaviorSubject(value: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        
        mainViewButtonDriver = mainViewButtonTapped.distinctUntilChanged().asDriver(onErrorJustReturn: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        rankViewButtonDriver = rankViewButtonTapped.distinctUntilChanged().asDriver(onErrorJustReturn: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        myViewButtonDriver = myViewButtonTapped.distinctUntilChanged().asDriver(onErrorJustReturn: URLRequest(url: URL(string: "http://www.blankwebsite.com/")!))
        
    }
    
    public func loginDataBindFirstPage(_ urlTarget:OneLineReview, _ subject:BehaviorSubject<URLRequest>) {
        userLoginSession.getLoginData()?.flatMap({ [weak self] data -> Observable<URLRequest> in
            let userData = ["memberId":data.data._id]
            let req = (self?.urlMaker.rxMakeLoginURLComponents(urlTarget, userData))!
            return req
        }).bind(to: subject)
            .disposed(by: disposeBag)
    }
    
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
            self.urlMaker.rxMakeLoginURLComponents(.contentDetailView, queryDict).bind(to: mainViewButtonTapped).disposed(by: disposeBag)
            return
        } else {
            decisionHandler(.cancel)
            return
        }
    }
}
