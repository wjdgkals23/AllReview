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
    
    private var webMainView: WKWebView!
    
    @IBOutlet var webContainer: UIView!
    @IBOutlet var searchBar: UITextField!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let navi = catchNavigation() {
            viewModel = SearchMovieViewModel()
            router = SearchMovieViewRouter(navigation: navi)
            bindingRx()
            webViewAddWebContainer()
        } else {
            self.viewDidLoad()
        }
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
    }
    
    private func webViewAddWebContainer() {
        
        let webMainViewWebConfigure = WKWebViewConfiguration()
        
        let cgRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.webMainView = WKWebView(frame: cgRect, configuration: webMainViewWebConfigure)
        
        self.webMainView.navigationDelegate = self
        
        let urlParserContext = { [weak self] (webView: WKWebView, response: WKNavigationAction, handler: (WKNavigationActionPolicy) -> Void) -> Void in
            
            let url = response.request.url?.absoluteString
            
            if((url?.contains("https://www.teammiracle.be/"))!) {
                handler(.allow)
                return
            }
            else if((url?.contains("app://writeContent"))!) {
                handler(.allow)
                let index = url?.firstIndex(of: "?") ?? url?.endIndex
                let temp = String((url?[index!...])!)
                let queryDict = temp.parseQueryString()
                self?.router.viewPresent("add", queryDict)
                return
            }
            else {
                handler(.cancel)
                return
            }
            
        }
        
        self.webMainView.rx.decidePolicyNavigationAction.subscribe(onNext: urlParserContext)
        
        self.webContainer.addSubview(webMainView)
        self.webMainView.translatesAutoresizingMaskIntoConstraints = true
        self.webMainView.leadingAnchor.constraint(equalTo: self.webContainer.leadingAnchor).isActive = true
        self.webMainView.trailingAnchor.constraint(equalTo: self.webContainer.trailingAnchor).isActive = true
        self.webMainView.topAnchor.constraint(equalTo: self.webContainer.topAnchor).isActive = true
        self.webMainView.bottomAnchor.constraint(equalTo: self.webContainer.bottomAnchor).isActive = true
        
        self.viewModel.searchResultSubject.asObservable().subscribe(onNext: { (request) in // DistinctChanged 를 못받는 이유는 URLRequest의 메인 host와 scheme이 변하지 않아서
            self.webMainView.load(request) // 실패화면 구현 요청
        }, onError: { (err) in
            print("Error \(err.localizedDescription)")
        }).disposed(by: disposeBag)
        
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        self.viewModel.searchKeywordBindResultPage(.searchMovie, self.searchBar.text!)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        if (self.webMainView.canGoBack) {
            print("cangoback")
            self.webMainView.goBack()
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
