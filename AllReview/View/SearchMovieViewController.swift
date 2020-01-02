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

class SearchMovieViewController: UIViewController, OneLineReviewViewProtocol {
    
    private var viewModel: SearchMovieViewModel!
    private var router: SearchMovieViewRouter!
    
    private var webSearchView: WKWebView!
    
    @IBOutlet var webContainer: UIView!
    
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var searchBar: UITextField!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    public var rankedSearchWord: String!
    private var navi:UINavigationController!
    
    var topSafeArea:CGFloat! {
        willSet(newValue){
            if(newValue != self.topSafeArea) {
                let webViewHeight = self.view.bounds.height - self.headerView.bounds.height - newValue
                let cgRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: webViewHeight)
                self.webSearchView.frame = cgRect
            }
        }
    }
    
    var bottomSafeArea:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let navi = catchNavigation() {
            self.navi = navi
            viewModel = SearchMovieViewModel()
            router = SearchMovieViewRouter(navigation: navi)
            searchBar.changeDefaultColor()
            setUpWebView()
            setUpRx()
            if rankedSearchWord != nil && rankedSearchWord != "" {
                self.viewModel.searchKeywordBindResultPage(.searchMovie, rankedSearchWord)
                self.searchBar.text = rankedSearchWord
            }
        } else {
            self.viewDidLoad()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        
        if #available(iOS 11.0, *) {
            bottomSafeArea = self.view.safeAreaInsets.bottom
            topSafeArea = self.view.safeAreaInsets.top
        } else {
            bottomSafeArea = self.bottomLayoutGuide.length
            topSafeArea = topLayoutGuide.length
        }
    }
    
    func setUpView() {}
    
    func setUpRx() {
        self.searchBar.rx.text.distinctUntilChanged()
            .bind(to: viewModel.keywordTextSubject)
            .disposed(by: self.viewModel.disposeBag)
        
        self.viewModel.searchButtonEnabledDriver
            .drive(self.searchButton.rx.isEnabled)
            .disposed(by: self.viewModel.disposeBag)
        
        self.viewModel.goToNewViewControllerReviewSubject
            .subscribe({ initData in
                self.router.viewPresent(initData.element!.0, initData.element!.1 as! Dictionary<String, String>)
            }).disposed(by: self.viewModel.disposeBag)
        
        self.viewModel.searchResultSubject.asObservable().subscribe(onNext: { (request) in // DistinctChanged 를 못받는 이유는 URLRequest의 메인 host와 scheme이 변하지 않아서
            guard let req = request else { return }
            self.webSearchView.load(req)
        }, onError: { (err) in
            print("Error \(err.localizedDescription)")
        }).disposed(by: self.viewModel.disposeBag)
        
        self.webSearchView.rx.decidePolicyNavigationAction
            .subscribe(onNext: self.viewModel.urlParserContext!)
            .disposed(by: self.viewModel.disposeBag)
        
        self.searchButton.rx.tap.bind{ [weak self] in
            self?.searchBar.resignFirstResponder()
            self?.viewModel.searchKeywordBindResultPage(.searchMovie, (self?.searchBar.text)!)
        }.disposed(by: self.viewModel.disposeBag)
        
        self.cancelButton.rx.tap.bind{ [weak self] in
            if ((self?.webSearchView.canGoBack)!) {
                self?.webSearchView.goBack()
                return
            } else {
                self?.navi.popViewController(animated: true)
            }
        }.disposed(by: self.viewModel.disposeBag)
    
    }
    
    func setUpWebView() {
        let webSearchViewWebConfigure = WKWebViewConfiguration()
        let webViewHeight = self.view.bounds.height
        let cgRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: webViewHeight)
        self.webSearchView = WKWebView(frame: cgRect, configuration: webSearchViewWebConfigure)
        
        self.webSearchView.navigationDelegate = self.viewModel
        
        self.webContainer.addSubview(webSearchView)
        self.webSearchView.translatesAutoresizingMaskIntoConstraints = true
        self.webSearchView.leadingAnchor.constraint(equalTo: self.webContainer.leadingAnchor).isActive = true
        self.webSearchView.trailingAnchor.constraint(equalTo: self.webContainer.trailingAnchor).isActive = true
        self.webSearchView.topAnchor.constraint(equalTo: self.webContainer.topAnchor).isActive = true
        self.webSearchView.bottomAnchor.constraint(equalTo: self.webContainer.bottomAnchor).isActive = true
        self.webSearchView.updateConstraints()
        
        self.webSearchView.scrollView.bounces = false
    }
    
    func reloadWebView() {
        self.webSearchView.reload()
    }
    
}
