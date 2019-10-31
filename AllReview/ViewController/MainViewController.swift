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
    
    private var webViewList: Array<WKWebView>!
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var bottomView: UIView!
    
    @IBOutlet var webContainer: UIView!
    
    @IBOutlet var mainViewButton: UIView!
    @IBOutlet var rankViewButton: UIView!
    @IBOutlet var myViewButton: UIView!
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
        
        let cgRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - self.bottomView.bounds.height-self.headerView.bounds.height)
        webMainView = WKWebView(frame: cgRect, configuration: webConfigure)
        webRankView = WKWebView(frame: cgRect, configuration: webConfigure)
        webMyView = WKWebView(frame: cgRect, configuration: webConfigure)

        
        webViewList = Array<WKWebView>()
        
        webViewList.append(webMyView)
        webViewList.append(webRankView)
        webViewList.append(webMainView)

        self.webMainView.uiDelegate = self
        self.webRankView.uiDelegate = self
        self.webMyView.uiDelegate = self
        
        webViewAddWebContainer()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(rankButtonTapped(_:)))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(rankButtonTapped(_:)))
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(rankButtonTapped(_:)))
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(rankButtonTapped(_:)))
        
        mainViewButton.isUserInteractionEnabled = true
        mainViewButton.addGestureRecognizer(tap)
        rankViewButton.isUserInteractionEnabled = true
        rankViewButton.addGestureRecognizer(tap2)
        myViewButton.isUserInteractionEnabled = true
        myViewButton.addGestureRecognizer(tap3)
        
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
            self?.webRankView.isHidden = true
            self?.webMyView.load(requests[2])
            self?.webMyView.isHidden = true
        }).disposed(by: disposeBag)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func webViewAddWebContainer() {
        for item in self.webViewList {
            self.webContainer.addSubview(item)
            item.translatesAutoresizingMaskIntoConstraints = true
            item.leadingAnchor.constraint(equalTo: self.webContainer.leadingAnchor).isActive = true
            item.trailingAnchor.constraint(equalTo: self.webContainer.trailingAnchor).isActive = true
            item.topAnchor.constraint(equalTo: self.webContainer.topAnchor).isActive = true
            item.bottomAnchor.constraint(equalTo: self.webContainer.bottomAnchor).isActive = true
        }
    }
    
    @objc func rankButtonTapped(_ sender: UITapGestureRecognizer) {
        self.webMyView.isHidden = true
        self.webRankView.isHidden = true
        self.webMainView.isHidden = true
        
        if(sender.view == self.mainViewButton) {
            self.webMainView.isHidden = false
        } else if (sender.view == self.rankViewButton) {
            self.webRankView.isHidden = false
        } else if (sender.view == self.myViewButton) {
            self.webMyView.isHidden = false
        }
    }
}
