//
//  MainViewController.swift
//  AllReview
//
//  Created by 정하민 on 2019/10/29.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import RxWebKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    private var userLoginSession = UserLoginSession.sharedInstance
    private var disposeBag = DisposeBag()
    
    private var viewModel: MainViewModel!
    
    private var webMainView: WKWebView!
    private var webRankView: WKWebView!
    private var webMyView: WKWebView!
    
    private var webViewList: Array<WKWebView>!
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var bottomView: UIStackView!
    
    @IBOutlet var webContainer: UIView!
    
    @IBOutlet var mainViewButton: UIButton!
    @IBOutlet var rankViewButton: UIButton!
    @IBOutlet var tempViewButton: UIButton!
    @IBOutlet var myViewButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = MainViewModel()
        
        let webMainViewWebConfigure = WKWebViewConfiguration()
        let webRankViewWebConfigure = WKWebViewConfiguration()
        let webMyViewWebConfigure = WKWebViewConfiguration()
        
        let cgRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - self.bottomView.bounds.height-self.headerView.bounds.height)
        webMainView = WKWebView(frame: cgRect, configuration: webMainViewWebConfigure)
        webRankView = WKWebView(frame: cgRect, configuration: webRankViewWebConfigure)
        webMyView = WKWebView(frame: cgRect, configuration: webMyViewWebConfigure)
        
        webViewList = Array<WKWebView>()
        
        webViewList.append(webMyView)
        webViewList.append(webRankView)
        webViewList.append(webMainView)
        
        self.webMainView.uiDelegate = self
        self.webMainView.navigationDelegate = self
        self.webRankView.uiDelegate = self
        self.webMyView.uiDelegate = self
        
        webViewAddWebContainer()
        buttonTapBind();
        initWebView();

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func webViewAddWebContainer() {
        for item in self.webViewList {
            self.webContainer.addSubview(item)
            item.translatesAutoresizingMaskIntoConstraints = true
            item.leadingAnchor.constraint(equalTo: self.webContainer.leadingAnchor).isActive = true
            item.trailingAnchor.constraint(equalTo: self.webContainer.trailingAnchor).isActive = true
            item.topAnchor.constraint(equalTo: self.webContainer.topAnchor).isActive = true
            item.bottomAnchor.constraint(equalTo: self.webContainer.bottomAnchor).isActive = true
        }
    }
    
    private func buttonTapBind() {
        
        mainViewButton.rx.tap.flatMap { _ -> Observable<[Bool]> in
            return self.buttonflatMap(webView: self.webMainView)
        }.subscribe(onNext: { [weak self] item in
            self?.webMainView.isHidden = item[0];
            self?.webMyView.isHidden = item[1]
            self?.webRankView.isHidden = item[1];
        }).disposed(by: disposeBag)
        
        rankViewButton.rx.tap.flatMap { _ -> Observable<[Bool]> in
            return self.buttonflatMap(webView: self.webRankView)
        }.subscribe(onNext: { [weak self] item in
            self?.webRankView.isHidden = item[0];
            self?.webMyView.isHidden = item[1]
            self?.webMainView.isHidden = item[1];
        }).disposed(by: disposeBag)
        
        myViewButton.rx.tap.flatMap { _ -> Observable<[Bool]> in
            return self.buttonflatMap(webView: self.webMyView)
        }.subscribe(onNext: { [weak self] item in
            self?.webMyView.isHidden = item[0];
            self?.webMainView.isHidden = item[1]
            self?.webRankView.isHidden = item[1];
        }).disposed(by: disposeBag)
        
    }
    
    private func initWebView() {
        userLoginSession.getLoginData()?.flatMap({ [weak self] data -> Observable<URLRequest> in
            let userData = ["memberId":data.data._id]
            let req = (self?.viewModel.urlMaker.rxMakeLoginURLComponents(.mainMainView, userData))!
            return req
        }).bind(to: viewModel.mainViewButtonTapped)
            .disposed(by: disposeBag)
        
        userLoginSession.getLoginData()?.flatMap({ [weak self] data -> Observable<URLRequest> in
            let userData = ["memberId":data.data._id]
            let req = (self?.viewModel.urlMaker.rxMakeLoginURLComponents(.mainRankView, userData))!
            return req
        }).bind(to: viewModel.rankViewButtonTapped)
            .disposed(by: disposeBag)
        
        userLoginSession.getLoginData()?.flatMap({ [weak self] data -> Observable<URLRequest> in
            let userData = ["memberId":data.data._id]
            let req = (self?.viewModel.urlMaker.rxMakeLoginURLComponents(.mainMyView, userData))!
            return req
        }).bind(to: viewModel.myViewButtonTapped)
            .disposed(by: disposeBag)
        
        viewModel.mainViewButtonDriver.asObservable().subscribe(onNext: { (request) in
            self.webMainView.load(request)
        }).disposed(by: disposeBag)
        
        viewModel.rankViewButtonDriver.asObservable().subscribe(onNext: { (request) in
            self.webRankView.load(request)
        }).disposed(by: disposeBag)
        
        viewModel.myViewButtonDriver.asObservable().subscribe(onNext: { (request) in
            self.webMyView.load(request)
        }).disposed(by: disposeBag)
    }
    
    private func buttonflatMap(webView: WKWebView) -> Observable<[Bool]> {
        return Observable.create { (obs) -> Disposable in
            if (!webView.isHidden) {
                obs.on(.next([webView.isHidden, !webView.isHidden]))
            } else {
                obs.on(.next([!webView.isHidden, webView.isHidden]))
            }
            return Disposables.create()
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let request = navigationAction.request
        let url = request.url?.absoluteString
        
        if((url?.contains("https://www.teammiracle.be"))!) {
            decisionHandler(.allow)
            return
        }
        else if((url?.contains("app://contentDetail"))!) {
            let index = url?.firstIndex(of: "?") ?? url?.endIndex
//            print(url?[index!+1...])
            let queryDict = url?[..<index!]
            decisionHandler(.allow)
            return
        } else {
            decisionHandler(.cancel)
            return
        }
    }
    
//    func webViewAppCallParsing(_ url: String) -> String {
//
//    }
//
//    func webViewURLParsing(_ url: String) -> String {
//
//    }
}

extension String {
    func parseQueryString() -> [String:String] {
        let returnDict = Dictionary<String,String>()
        let tempArray = self.split(separator: "&")
        print(tempArray)
        return returnDict
    }
}
