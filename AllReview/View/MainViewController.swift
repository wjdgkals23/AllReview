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

class MainViewController: UIViewController, OneLineRevieViewControllerType {
    
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
    
    private var topMargin:CGFloat! = 0 {
        willSet(newValue) {
            self.viewList.forEach { (webView) in
                webView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.view.bounds.height - self.bottomView.bounds.height - self.headerView.bounds.height - newValue)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        if #available(iOS 11.0, *){
            topMargin = self.view.safeAreaInsets.top
        } else {
            topMargin = self.topLayoutGuide.length
        }
    }
    
    func setUpView() {
        return
    }
    
    func setUpRx() {
        self.viewModel.mainURLRequest.subscribe(onNext: { [weak self] request in
            self?.webMainView.load(request)
        }, onError: { [weak self] (error) in
            self?.showToast(message: error.localizedDescription, font: UIFont.systemFont(ofSize: 18, weight: .bold), completion: nil)
        }).disposed(by: self.disposeBag)
        
        self.viewModel.rankURLRequest.subscribe(onNext: { [weak self] request in
            self?.webRankView.load(request)
        }, onError: { [weak self] (error) in
            self?.showToast(message: error.localizedDescription, font: UIFont.systemFont(ofSize: 18, weight: .bold), completion: nil)
        }).disposed(by: self.disposeBag)
        
        self.viewModel.myURLRequest.subscribe(onNext: { [weak self] request in
            self?.webMyView.load(request)
        }, onError: { [weak self] (error) in
            self?.showToast(message: error.localizedDescription, font: UIFont.systemFont(ofSize: 18, weight: .bold), completion: nil)
        }).disposed(by: self.disposeBag) 
    
        
        self.mainViewButton.rx.tap.bind{ [weak self] in self?.statusSettingFunc(self!.mainViewButton) }.disposed(by: self.viewModel.disposeBag)
        self.rankViewButton.rx.tap.bind{ [weak self] in self?.statusSettingFunc(self!.rankViewButton) }.disposed(by: self.viewModel.disposeBag)
        self.myViewButton.rx.tap.bind{ [weak self] in self?.statusSettingFunc(self!.myViewButton) }.disposed(by: self.viewModel.disposeBag)
        self.backButton.rx.tap.bind{ [weak self] in self?.backButtonTapped() }.disposed(by: self.viewModel.disposeBag)
        self.tempViewButton.rx.tap.bind(to: self.viewModel.pushSearchViewSubject).disposed(by: self.viewModel.disposeBag)
        self.searchButton.rx.tap.bind(to: self.viewModel.pushSearchViewSubject).disposed(by: self.viewModel.disposeBag)
    }
    
    func setUpWebView() {
        self.webMainView = WKWebView()
        self.webRankView = WKWebView()
        self.webMyView = WKWebView()
        
        self.viewList = [self.webMyView,self.webRankView,self.webMainView]
        
        for item in self.viewList {
            self.containerView.addSubview(item)
        }
        
        self.webMainView.navigationDelegate = self
        self.webMyView.navigationDelegate = self
        self.webRankView.navigationDelegate = self
        
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
        
        self.showToast(message: "로그인/로그아웃/리뷰등록 만 남았다!", font: UIFont.systemFont(ofSize: 18, weight: .semibold), completion: nil)
    }
    
}

extension MainViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url?.absoluteString
        
        if((url?.contains("https://www.teammiracle.be"))!) {
            decisionHandler(.allow)
            return
        } else {
            let index = url?.firstIndex(of: "?") ?? url?.endIndex
            let temp = String((url?[index!...])!)
            var queryDict:[String: String] = [:]
            if temp != "" {
                queryDict = temp.parseQueryString() // queryDict가 Parse를 못하는 상황이 있을수도!!
            }
            
            if((url?.contains("app://SearchMovie"))!) {
                decisionHandler(.allow)
                var searchKeyword: String? = nil
                if let ind = index, ind != url!.endIndex {
                    searchKeyword = queryDict["movieNm"]
                }
                
                let searchVM = SearchMovieViewModel(keyword: searchKeyword)
                let searchScene = Scene.search(searchVM)
                
                self.viewModel.sceneCoordinator.transition(to: searchScene, using: .push, animated: false)
            }
            else if((url?.contains("app://ShareContent"))!) {
                decisionHandler(.allow)
                print(queryDict["url"]?.decodeUrl())
            }
            else if((url?.contains("app://ShareScreenshot"))!) {
                decisionHandler(.allow)
//                let capturedImage = self.takeScreenShot()
                
//                let coordinator = SceneCoordinator.init(window: UIApplication.shared.keyWindow!)
//                let modalVM = ImageModalViewModel(sceneCoordinator: coordinator, image: capturedImage)
//                let modalScene = Scene.modal(modalVM)
//                self?.sceneCoordinator.transition(to: modalScene, using: .modal, animated: false).subscribe().disposed(by: self!.disposeBag)
                
            }
            else {
                decisionHandler(.allow)
                return
            }
        }
    }
}
