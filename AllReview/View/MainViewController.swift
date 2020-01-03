//
//  NonBottomViewController.swift
//  AllReview
//
//  Created by 정하민 on 2019/12/16.
//  Copyright © 2019 swift. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WebKit
import RxWebKit


protocol OneLineReviewViewProtocol {
    
    associatedtype ViewModelType
    
    var viewModel: ViewModelType! { get set }
    
    func setUpView()
    func setUpRx()
    func setUpWebView()
    
}

extension OneLineReviewViewProtocol where Self: UIViewController {
    mutating func bind(viewModel: Self.ViewModelType) {
        self.viewModel = viewModel
        loadViewIfNeeded()
        setUpView()
        setUpWebView()
        setUpRx()
    }
}

class MainViewController: UIViewController, OneLineReviewViewProtocol {
    
    var viewModel: MainViewModel!
    var disposeBag = DisposeBag()
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var titleImageVIew: UIImageView!
    
    @IBOutlet var containerView: UIView! // containerChange 함수 필요!
    
    private var webMainView: WKWebView!
    private var webRankView: WKWebView!
    private var webMyView: WKWebView!
    
    private var viewList: Array<UIView>!
    
    @IBOutlet var bottomView: UIStackView!
    
    @IBOutlet var mainViewButton: UIButton!
    @IBOutlet var rankViewButton: UIButton!
    @IBOutlet var tempViewButton: UIButton!
    @IBOutlet var myViewButton: UIButton!
    
    var topSafeArea:CGFloat! {
        willSet(newValue){
            if(newValue != self.topSafeArea) {
                let topTotalHeight = self.headerView.bounds.height + newValue
                let webViewHeight = self.view.bounds.height - topTotalHeight
                let beforeRect = self.containerView.frame
                let cgRect = CGRect(x: beforeRect.origin.x, y: beforeRect.origin.y, width: beforeRect.width, height: webViewHeight)
                self.containerView.frame = cgRect
            }
        }
    }
    var bottomSafeArea:CGFloat!
    
    override func viewDidLayoutSubviews() {
        if #available(iOS 11.0, *) {
            topSafeArea = self.view.safeAreaInsets.top
            bottomSafeArea = self.view.safeAreaInsets.bottom
        } else {
            topSafeArea = topLayoutGuide.length
            bottomSafeArea = bottomLayoutGuide.length
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.superview?.backgroundColor = .white
    }
    
    func setUpView() {
        
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
        
        self.viewModel.loginDataBindFirstPage(.mainMainView, self.viewModel.mainViewRequestSubject)
        self.viewModel.loginDataBindFirstPage(.mainRankView, self.viewModel.rankViewRequestSubject)
        self.viewModel.loginDataBindFirstPage(.mainMyView, self.viewModel.myViewRequestSubject)
        
        self.viewModel.mainViewRequestSubject.asObservable().subscribe(onNext: { (request) in
            guard let req = request else { return self.showToast(message: "메인화면 로드 실패", font: UIFont.systemFont(ofSize: 18, weight: .semibold)) }
            self.webMainView.load(req)
        }, onError: { (err) in
            print("Err \(err)")
        }).disposed(by: disposeBag)
        
        self.viewModel.rankViewRequestSubject.asObservable().subscribe(onNext: { (request) in
            guard let req = request else { return self.showToast(message: "메인화면 로드 실패", font: UIFont.systemFont(ofSize: 18, weight: .semibold)) }
            self.webRankView.load(req)
        }, onError: { (err) in
            print("Err \(err)")
        }).disposed(by: disposeBag)
        
        self.viewModel.myViewRequestSubject.asObservable().subscribe(onNext: { (request) in
            guard let req = request else { return self.showToast(message: "메인화면 로드 실패", font: UIFont.systemFont(ofSize: 18, weight: .semibold)) }
            self.webMyView.load(req)
        }, onError: { (err) in
            print("Err \(err)")
        }).disposed(by: disposeBag)
        
        self.viewModel.goToMyContentDetailViewSubject.subscribe(onNext: { [weak self] query in
            if (!(self?.webMyView.isHidden)!) {
                self?.viewModel.makePageURLRequest(.contentDetailView, query, ((self?.viewModel.myViewRequestSubject)!))
            } else if(!(self?.webMainView.isHidden)!) {
                self?.viewModel.makePageURLRequest(.contentDetailView, query, ((self?.viewModel.mainViewRequestSubject)!))
            } else {
                self?.viewModel.makePageURLRequest(.contentDetailView, query, ((self?.viewModel.rankViewRequestSubject)!))
            }
            }, onError: { [weak self] err in
                self?.showToast(message: err.localizedDescription, font: UIFont.systemFont(ofSize: 17, weight: .semibold))
        })
        
        self.mainViewButton.rx.tap.bind{ [weak self] in self?.statusSettingFunc(self!.mainViewButton) }.disposed(by: self.viewModel.disposeBag)
        self.rankViewButton.rx.tap.bind{ [weak self] in self?.statusSettingFunc(self!.rankViewButton) }.disposed(by: self.viewModel.disposeBag)
        self.myViewButton.rx.tap.bind{ [weak self] in self?.statusSettingFunc(self!.myViewButton) }.disposed(by: self.viewModel.disposeBag)
        self.backButton.rx.tap.bind{ [weak self] in self?.backButtonTapped() }.disposed(by: self.viewModel.disposeBag)
        self.tempViewButton.rx.tap.bind{ [weak self] in self?.viewModel.pushSearchView() }.disposed(by: self.viewModel.disposeBag)
        self.searchButton.rx.tap.bind{ [weak self] in self?.viewModel.pushSearchView() }.disposed(by: self.viewModel.disposeBag)
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
            self.containerView.addSubview(item)
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
    
    private func statusSettingFunc(_ sender: UIButton) {
        self.webMainView.isHidden = true
        self.webMyView.isHidden = true
        self.webRankView.isHidden = true
        self.mainViewButton.isSelected = false
        self.rankViewButton.isSelected = false
        self.myViewButton.isSelected = false
        self.titleImageVIew.image = #imageLiteral(resourceName: "title")
        
        sender.isSelected = true
        
        switch sender {
        case self.mainViewButton:
            self.webMainView.isHidden = false
        case self.myViewButton:
            self.webMyView.isHidden = false
        case self.rankViewButton:
            self.webRankView.isHidden = false
            self.titleImageVIew.image = #imageLiteral(resourceName: "title2")
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
    
    func backButtonTapped() {
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
