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
import RxSwift
import RxCocoa

class MainViewController: UIViewController, WKUIDelegate {
    
    private var urlMaker = OneLineReviewURL()
    private var userLoginSession = UserLoginSession.sharedInstance
    private var disposeBag = DisposeBag()
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var bottomView: UIView!
    
    lazy var webView: WKWebView = {
        let wv = WKWebView()
        wv.uiDelegate = self
        wv.translatesAutoresizingMaskIntoConstraints = false
        return wv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userLoginSession.getLoginData()?.flatMap({ [weak self] data -> Observable<URLRequest> in
            let userData = ["memberId":data.data._id]
            return (self?.urlMaker.rxMakeLoginURLComponents(.mainMainView, userData))!
        }).subscribe(onNext: { [weak self] request in
            self?.view.addSubview(self!.webView)
            self?.webView.load(request)
        }).disposed(by: disposeBag)
        
        if #available(iOS 11, *) {
          NSLayoutConstraint.activate([
          webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
          webView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
          webView.rightAnchor.constraint(equalTo: view.rightAnchor),
          webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])

        } else {
           NSLayoutConstraint.activate([
           webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
           webView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8),
           webView.rightAnchor.constraint(equalTo: view.rightAnchor),
           webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        }
    
    }
}
