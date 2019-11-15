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
    private var disposeBles = Disposables.create()
    
    private var viewModel: SearchMovieViewModel!
    private var router: MainRouter!
    
    private var webMainView: WKWebView!

    @IBOutlet var webContainer: UIView!
    @IBOutlet var searchBar: UITextField!
    @IBOutlet var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webViewAddWebContainer()
        // Do any additional setup after loading the view.
        viewModel = SearchMovieViewModel()
        
        let searchKeywordValid = self.searchBar.rx.text.map{ $0!.count > 1 }
        searchKeywordValid
            .bind(to: viewModel.searchBarSubject)
            .disposed(by: disposeBag)
        
        viewModel.searchButtonEnabledDriver
            .drive(self.searchButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        self.searchButton.rx.tap.flatMap { _ -> Observable<String> in
            return 
        }
    }
    
    private func webViewAddWebContainer() {
        
        let webMainViewWebConfigure = WKWebViewConfiguration()
        
        let cgRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        webMainView = WKWebView(frame: cgRect, configuration: webMainViewWebConfigure)
        
        self.webMainView.uiDelegate = self.viewModel
        self.webMainView.navigationDelegate = self.viewModel
        
        self.webContainer.addSubview(webMainView)
        webMainView.translatesAutoresizingMaskIntoConstraints = true
        webMainView.leadingAnchor.constraint(equalTo: self.webContainer.leadingAnchor).isActive = true
        webMainView.trailingAnchor.constraint(equalTo: self.webContainer.trailingAnchor).isActive = true
        webMainView.topAnchor.constraint(equalTo: self.webContainer.topAnchor).isActive = true
        webMainView.bottomAnchor.constraint(equalTo: self.webContainer.bottomAnchor).isActive = true
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
