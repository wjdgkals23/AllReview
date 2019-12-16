//
//  SearchMovieViewController.swift
//  AllReview
//
//  Created by 정하민 on 2019/11/15.
//  Copyright © 2019 swift. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WebKit
import RxWebKit

class SearchMovieViewController: UIViewController, WKNavigationDelegate {
    
    private var disposeBag = DisposeBag()
    
    private var viewModel: SearchMovieViewModel!
    private var router: SearchMovieViewRouter!
    
    private var webSearchView: WKWebView!
    
    @IBOutlet var webContainer: UIView!
    @IBOutlet var searchBar: UITextField!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    var topSafeArea:CGFloat!
    var bottomSafeArea:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let navi = catchNavigation() {
            viewModel = SearchMovieViewModel()
            router = SearchMovieViewRouter(navigation: navi)
            
        } else {
            self.viewDidLoad()
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        if #available(iOS 11.0, *) {
            topSafeArea = self.view.safeAreaInsets.top
            bottomSafeArea = self.view.safeAreaInsets.bottom
        } else {
            topSafeArea = topLayoutGuide.length
            bottomSafeArea = self.bottomLayoutGuide.length
        }
        webViewAddWebContainer()
        bindingRx()
    }
    
    private func bindingRx() {
        self.searchBar.rx.text.distinctUntilChanged()
            .bind(to: viewModel.keywordTextSubject)
            .disposed(by: disposeBag)
        
        self.viewModel.searchButtonEnabledDriver
            .drive(self.searchButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        self.viewModel.goToAddNewReviewSubject
            .subscribe({ initData in
                self.router.viewPresent(initData.element!.0, initData.element!.1)
            }).disposed(by: self.disposeBag)
        
        self.viewModel.searchResultSubject.asObservable().subscribe(onNext: { (request) in // DistinctChanged 를 못받는 이유는 URLRequest의 메인 host와 scheme이 변하지 않아서
            self.webSearchView.load(request) // 실패화면 구현 요청
        }, onError: { (err) in
            print("Error \(err.localizedDescription)")
        }).disposed(by: disposeBag)
    }
    
    private func webViewAddWebContainer() {
        
        let webSearchViewWebConfigure = WKWebViewConfiguration()
        let webViewHeight = self.view.bounds.height - topSafeArea
        let cgRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: webViewHeight)
        self.webSearchView = WKWebView(frame: cgRect, configuration: webSearchViewWebConfigure)
        
        self.webSearchView.navigationDelegate = self.viewModel
        self.webSearchView.rx.decidePolicyNavigationAction.subscribe(onNext: self.viewModel.urlParserContext)
        
        self.webContainer.addSubview(webSearchView)
        self.webSearchView.translatesAutoresizingMaskIntoConstraints = true
        self.webSearchView.leadingAnchor.constraint(equalTo: self.webContainer.leadingAnchor).isActive = true
        self.webSearchView.trailingAnchor.constraint(equalTo: self.webContainer.trailingAnchor).isActive = true
        self.webSearchView.topAnchor.constraint(equalTo: self.webContainer.topAnchor).isActive = true
        self.webSearchView.bottomAnchor.constraint(equalTo: self.webContainer.bottomAnchor).isActive = true
        self.webSearchView.updateConstraints()
    
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        self.viewModel.searchKeywordBindResultPage(.searchMovie, self.searchBar.text!)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        if (self.webSearchView.canGoBack) {
            print("cangoback")
            //            self.webSearchView.go(to: WKBackForwardListItem)
            self.webSearchView.goBack()
        } else {
            if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                navigationController.popViewController(animated: true)
            }
            else {
                print("View Load Fail")
            }
        }
    }
    
}
