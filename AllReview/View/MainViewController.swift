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

class MainViewController: UIViewController, WKNavigationDelegate {
    
    private var disposeBag = DisposeBag()
    
    private var viewModel: MainViewModel!
    private var router: DefaultRouter!
    
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
    
    @IBOutlet var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var headerViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.superview?.backgroundColor = .white
        if let navi = catchNavigation() {
            viewModel = MainViewModel()
            router = MainRouter(navigation: navi)
            navi.isNavigationBarHidden = true;
            webViewAddWebContainer()
            buttonTapBind();
            initWebView();
        } else {
            self.viewDidLoad()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func webViewAddWebContainer() {
        
        let webMainViewWebConfigure = WKWebViewConfiguration()
        let webRankViewWebConfigure = WKWebViewConfiguration()
        let webMyViewWebConfigure = WKWebViewConfiguration()
        
        let cgRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - self.bottomView.bounds.height-self.headerView.bounds.height)
        self.webMainView = WKWebView(frame: cgRect, configuration: webMainViewWebConfigure)
        self.webRankView = WKWebView(frame: cgRect, configuration: webRankViewWebConfigure)
        self.webMyView = WKWebView(frame: cgRect, configuration: webMyViewWebConfigure)
        
        self.webViewList = [self.webMyView,self.webRankView,self.webMainView]
        
        self.webMainView.navigationDelegate = self
        self.webMyView.navigationDelegate = self
//        (Event<(WKWebView, WKNavigationAction, (WKNavigationActionPolicy) -> Void)>) -> Void)        
        
        let urlParserContext = { [weak self] (webView: WKWebView, response: WKNavigationAction, handler: (WKNavigationActionPolicy) -> Void) -> Void in
            
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
                print(webView.title)
                if(webView.title == "마이페이지") {
                    self?.viewModel.loadPageView(.contentDetailView, queryDict, (self?.viewModel.myViewRequestSubject)!)
                } else if (webView.title == "메인 신규리스트") {
                    self?.viewModel.loadPageView(.contentDetailView, queryDict, (self?.viewModel.mainViewRequestSubject)!)
                }
                return
            }
            else {
                handler(.cancel)
                return
            }
        }

        self.webMainView.rx.decidePolicyNavigationAction.asObservable()
            .subscribe(onNext: urlParserContext)
            .disposed(by: disposeBag)
        
        self.webMyView.rx.decidePolicyNavigationAction.asObservable()
            .subscribe(onNext: urlParserContext)
            .disposed(by: disposeBag)
        
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
        
        self.mainViewButton.rx.tap.flatMap { _ -> Observable<[Bool]> in
            return self.buttonflatMap(webView: self.webMainView)
        }.subscribe(onNext: { [weak self] item in
            self?.webMainView.isHidden = item[0];
            self?.webMyView.isHidden = item[1]
            self?.webRankView.isHidden = item[1];
        }).disposed(by: disposeBag)
        
        self.rankViewButton.rx.tap.flatMap { _ -> Observable<[Bool]> in
            return self.buttonflatMap(webView: self.webRankView)
        }.subscribe(onNext: { [weak self] item in
            self?.webRankView.isHidden = item[0];
            self?.webMyView.isHidden = item[1]
            self?.webMainView.isHidden = item[1];
        }).disposed(by: disposeBag)
        
        self.myViewButton.rx.tap.flatMap { _ -> Observable<[Bool]> in
            return self.buttonflatMap(webView: self.webMyView)
        }.subscribe(onNext: { [weak self] item in
            self?.webMyView.isHidden = item[0];
            self?.webMainView.isHidden = item[1]
            self?.webRankView.isHidden = item[1];
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
    
    private func initWebView() {
        
        self.viewModel.loginDataBindFirstPage(.mainMainView, self.viewModel.mainViewRequestSubject)
        self.viewModel.loginDataBindFirstPage(.mainRankView, self.viewModel.rankViewRequestSubject)
        self.viewModel.loginDataBindFirstPage(.mainMyView, self.viewModel.myViewRequestSubject)
        
        self.viewModel.mainViewRequestSubject.asObservable().subscribe(onNext: { (request) in
            self.webMainView.load(request)
        }, onError: { (err) in
            print("Err \(err)")
        }).disposed(by: disposeBag)
        
        self.viewModel.rankViewRequestSubject.asObservable().subscribe(onNext: { (request) in
            self.webRankView.load(request)
        }, onError: { (err) in
            print("Err \(err)")
        }).disposed(by: disposeBag)
        
        self.viewModel.myViewRequestSubject.asObservable().subscribe(onNext: { (request) in
            self.webMyView.load(request)
        }, onError: { (err) in
            print("Err \(err)")
        }).disposed(by: disposeBag)
        
        
    }
    
    @IBAction func addNewReviewButtonTapped(_ sender: Any) {
        self.router.viewPresent("add", ["":""])
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        if(self.webMainView.canGoBack && !self.webMainView.isHidden) {
            self.webMainView.goBack()
        }
        if(self.webRankView.canGoBack && !self.webRankView.isHidden) {
            self.webRankView.goBack()
        }
        if(self.webMyView.canGoBack && !self.webMyView.isHidden) {
            self.webMyView.goBack()
        }
    }
}
