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

class SearchMovieViewController: UIViewController {
    
    private var disposeBag = DisposeBag()
    
    private var viewModel: SearchMovieViewModel!
    private var router: MainRouter!
    
    private var webMainView: WKWebView!
    
    @IBOutlet var webContainer: UIView!
    @IBOutlet var searchBar: UITextField!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel = SearchMovieViewModel()
        webViewAddWebContainer()
        
        self.searchBar.rx.text.distinctUntilChanged()
            .bind(to: viewModel.keywordTextSubject)
            .disposed(by: disposeBag)
        
        viewModel.searchButtonEnabledDriver
            .drive(self.searchButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
    }
    
    private func webViewAddWebContainer() {
        
        let webMainViewWebConfigure = WKWebViewConfiguration()
        
        let cgRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.webMainView = WKWebView(frame: cgRect, configuration: webMainViewWebConfigure)
        
        self.webMainView.uiDelegate = self.viewModel
        self.webMainView.navigationDelegate = self.viewModel
        
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
