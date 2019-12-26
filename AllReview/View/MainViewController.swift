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

class MainViewController: UIViewController, OneLineReviewViewProtocol {
    
    private var disposeBag = DisposeBag()
    
    private var viewModel: MainViewModel!
    private var router: DefaultRouter!
    
    private unowned var parentView: NonBottomViewController!
    
    private var webMainView: WKWebView!
    private var webRankView: WKWebView!
    private var webMyView: WKWebView!
    
    private var viewList: Array<UIView>!
    
    @IBOutlet var bottomView: UIStackView!
    
    @IBOutlet var webContainer: UIView!
    
    @IBOutlet var mainViewButton: UIButton!
    @IBOutlet var rankViewButton: UIButton!
    @IBOutlet var tempViewButton: UIButton!
    @IBOutlet var myViewButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.superview?.backgroundColor = .white
        
        if let navi = catchNavigation() {
            viewModel = MainViewModel()
            router = MainRouter(navigation: navi)
            navi.isNavigationBarHidden = true;
        } else {
            self.viewDidLoad()
        }
        
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if let `parent` = parent as! NonBottomViewController? {
            self.parentView = parent
            self.parentView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
            self.view.frame = self.parentView.containerView.bounds
            setUpView()
            setUpWebView()
            setUpRx()
        }
    }
    
    func setUpView() {
        self.parentView.searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }
    
    func setUpRx() {
        self.webMainView.rx.decidePolicyNavigationAction.asObservable()
            .subscribe(onNext: self.viewModel.urlParserContext!)
            .disposed(by: disposeBag)
        
        self.webMyView.rx.decidePolicyNavigationAction.asObservable()
            .subscribe(onNext: self.viewModel.urlParserContext!)
            .disposed(by: disposeBag)
        
        self.webRankView.rx.decidePolicyNavigationAction.asObservable()
            .subscribe(onNext: self.viewModel.urlParserContext!)
            .disposed(by: disposeBag)
        
        self.viewModel.goToNewViewControllerReviewSubject
            .subscribe({ initData in
                self.router.viewPresent(initData.element!.0, initData.element!.1)
            }).disposed(by: self.viewModel.disposeBag)
        
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
        
        self.viewModel.goToMyContentDetailViewSubject.subscribe(onNext: { [weak self] query in
                if (!(self?.webMyView.isHidden)!) {
                    self?.viewModel.loadPageView(.contentDetailView, query, ((self?.viewModel.myViewRequestSubject)!))
                } else if(!(self?.webMainView.isHidden)!) {
                    self?.viewModel.loadPageView(.contentDetailView, query, ((self?.viewModel.mainViewRequestSubject)!))
                } else {
                    self?.viewModel.loadPageView(.contentDetailView, query, ((self?.viewModel.rankViewRequestSubject)!))
                }
            }, onError: { [weak self] err in
                self?.showToast(message: err.localizedDescription, font: UIFont.systemFont(ofSize: 17, weight: .semibold))
        })
    }
    
    func setUpWebView() {
        let webMainViewWebConfigure = WKWebViewConfiguration()
        let webRankViewWebConfigure = WKWebViewConfiguration()
        let webMyViewWebConfigure = WKWebViewConfiguration()
        
        let cgRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.view.bounds.height - self.bottomView.bounds.height) // frame 자체도 빼고
        
        self.webMainView = WKWebView(frame: cgRect, configuration: webMainViewWebConfigure)
        self.webRankView = WKWebView(frame: cgRect, configuration: webRankViewWebConfigure)
        self.webMyView = WKWebView(frame: cgRect, configuration: webMyViewWebConfigure)
        
        self.viewList = [self.webMyView,self.webRankView,self.webMainView]
        
        for item in self.viewList {
            self.webContainer.addSubview(item)
        }
        
        self.webMainView.navigationDelegate = self.viewModel
        self.webMyView.navigationDelegate = self.viewModel
        self.webRankView.navigationDelegate = self.viewModel
        
        self.webMainView.isHidden = false
        self.webMyView.isHidden = true
        self.webRankView.isHidden = true
        self.mainViewButton.isSelected = true
        self.rankViewButton.isSelected = false
        
        self.webMyView.scrollView.bounces = false
        self.webRankView.scrollView.bounces = false
        self.webMainView.scrollView.bounces = false
    }
    
    func reloadWebView() {
        self.webMyView.reload()
        self.webMainView.reload()
    }
    
    private func statusSettingFunc(_ sender: UIButton) {
        self.webMainView.isHidden = true
        self.webMyView.isHidden = true
        self.webRankView.isHidden = true
        self.mainViewButton.isSelected = false
        self.rankViewButton.isSelected = false
        self.myViewButton.isSelected = false
        self.parentView.titleImageVIew.image = #imageLiteral(resourceName: "title")
        
        sender.isSelected = true
        
        switch sender {
        case self.mainViewButton:
            self.webMainView.isHidden = false
        case self.myViewButton:
            self.webMyView.isHidden = false
        case self.rankViewButton:
            self.webRankView.isHidden = false
            self.parentView.titleImageVIew.image = #imageLiteral(resourceName: "title2")
        default:
            return
        }
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
    
    @objc private func searchButtonTapped() {
        self.router.viewPresent("add", ["":""])
    }
    
    @IBAction func setBottomViewStatus(_ sender: Any) {
        let targetButton = sender as! UIButton
        self.statusSettingFunc(targetButton)
    }
    
    @IBAction func addNewReviewButtonTapped(_ sender: Any) {
        self.router.viewPresent("add", ["":""])
    }
    
    @objc func backButtonTapped() {
        if(self.webMainView.canGoBack && !self.webMainView.isHidden) {
            self.webMainView.goBack()
            return
        }
        if(self.webRankView.canGoBack && !self.webRankView.isHidden) {
            self.webRankView.goBack()
            return
        }
        if(self.webMyView.canGoBack && !self.webMyView.isHidden) {
            self.webMyView.goBack()
            return
        }
        
        self.showToast(message: "로그인/로그아웃/리뷰등록 만 남았다!", font: UIFont.systemFont(ofSize: 18, weight: .semibold))
    }
}
