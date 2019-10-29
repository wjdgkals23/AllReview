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
    
    private var webMainView: WKWebView!
    private var webRankView: WKWebView!
    private var webMyView: WKWebView!
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var bottomView: UIView!
    
    @IBOutlet var webContainer: UIView!
    
    @IBOutlet var rankViewButton: UIView!
    //    lazy var webView: WKWebView = {
//        let wv = WKWebView()
//        wv.uiDelegate = self
//        wv.translatesAutoresizingMaskIntoConstraints = false
//        return wv
//    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        let webConfigure = WKWebViewConfiguration()
        webMainView = WKWebView(frame: .zero, configuration: webConfigure)
        webRankView = WKWebView(frame: .zero, configuration: webConfigure)
        webMyView = WKWebView(frame: .zero, configuration: webConfigure)
        
        self.webMainView.uiDelegate = self
        self.webRankView.uiDelegate = self
        self.webMyView.uiDelegate = self
        
        let rect = self.webContainer.frame
        self.webMainView.frame = CGRect(x:0,y:0,width:rect.size.width,height:rect.size.height)
        self.webRankView.frame = CGRect(x:0,y:0,width:rect.size.width,height:rect.size.height)
        self.webMyView.frame = CGRect(x:0,y:0,width:rect.size.width,height:rect.size.height)
        
        self.webContainer.addSubview(webMainView)
        
        rankViewButton.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(rankButtonTapped))
        rankViewButton.addGestureRecognizer(tap)
        
        userLoginSession.getLoginData()?.flatMap({ [weak self] data -> Observable<[URLRequest]> in
            let userData = ["memberId":data.data._id]
            let ob1 = (self?.urlMaker.rxMakeLoginURLComponents(.mainMainView, userData))!
            let ob2 = (self?.urlMaker.rxMakeLoginURLComponents(.mainRankView, userData))!
            let ob3 = (self?.urlMaker.rxMakeLoginURLComponents(.mainMyView, userData))!
            return Observable.combineLatest(ob1,ob2,ob3) { (a,b,c) -> [URLRequest] in
                var array = Array<URLRequest>()
                array.append(a)
                array.append(b)
                array.append(c)
                return array
            }
        }).subscribe(onNext: { [weak self] requests in
            self?.webMainView.load(requests[0])
            self?.webRankView.load(requests[1])
            self?.webMyView.load(requests[2])
        }).disposed(by: disposeBag)
    
//        if #available(iOS 11, *) {
//          NSLayoutConstraint.activate([
//          webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//          webView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
//          webView.rightAnchor.constraint(equalTo: view.rightAnchor),
//          webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
//
//        } else {
//           NSLayoutConstraint.activate([
//           webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//           webView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8),
//           webView.rightAnchor.constraint(equalTo: view.rightAnchor),
//           webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
//        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    @objc func rankButtonTapped() {
        self.webContainer.subviews[0].removeFromSuperview()
        self.webContainer.addSubview(self.webRankView)
    }
}
