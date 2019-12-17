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
import RxWebKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {
    
    private var disposeBag = DisposeBag()
    
    private var viewModel: MainViewModel!
    private var router: DefaultRouter!
    
    private var webMainView: WKWebView!
    private var webRankView: WKWebView!
    private var webMyView: WKWebView!
    
    private var viewList: Array<UIView>!
    
    //    @IBOutlet var headerView: UIView!
    @IBOutlet var bottomView: UIStackView!
    
    @IBOutlet var webContainer: UIView!
    
    @IBOutlet var mainViewButton: UIButton!
    @IBOutlet var rankViewButton: UIButton!
    @IBOutlet var tempViewButton: UIButton!
    @IBOutlet var myViewButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.superview?.backgroundColor = .white
        
        if let navi = catchNavigation() {
            viewModel = MainViewModel()
            router = MainRouter(navigation: navi)
            navi.isNavigationBarHidden = true;
        } else {
            self.viewDidLoad()
        }
        
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if let `parent` = parent as! NonBottomViewController? {
            parent.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
            self.view.frame = parent.containerView.bounds
            webViewAddWebContainer()
            buttonTapBind()
            bindWebView()
            bindRx()
        }
    }
    
    private func webViewAddWebContainer() {
        
        let webMainViewWebConfigure = WKWebViewConfiguration()
        let webRankViewWebConfigure = WKWebViewConfiguration()
        let webMyViewWebConfigure = WKWebViewConfiguration()
        
        let cgRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.view.bounds.height - self.bottomView.bounds.height) // frame 자체도 빼고 
        
        self.webMainView = WKWebView(frame: cgRect, configuration: webMainViewWebConfigure)
        self.webRankView = WKWebView(frame: cgRect, configuration: webRankViewWebConfigure)
        self.webMyView = WKWebView(frame: cgRect, configuration: webMyViewWebConfigure)
        
        self.viewList = [self.webMyView,self.webRankView,self.webMainView]
        
        for item in self.viewList {
            self.webContainer.addSubview(item)
        }
        
        self.webMainView.navigationDelegate = self.viewModel
        self.webMyView.navigationDelegate = self.viewModel
        
        self.webMainView.rx.decidePolicyNavigationAction.asObservable()
            .subscribe(onNext: self.viewModel.urlParserContext!)
            .disposed(by: disposeBag)
        
        self.webMyView.rx.decidePolicyNavigationAction.asObservable()
            .subscribe(onNext: self.viewModel.urlParserContext!)
            .disposed(by: disposeBag)
        
        self.viewModel.goToNewViewControllerReviewSubject
            .subscribe({ initData in
                self.router.viewPresent(initData.element!.0, initData.element!.1)
            }).disposed(by: self.disposeBag)
        
    }
    
    func setBottomViewStatus(onOff: Bool, color: CGColor) {
        self.webMainView.isHidden = onOff
        self.webMyView.isHidden = !onOff
        self.webRankView.isHidden = !onOff
        self.mainViewButton.isSelected = onOff
        self.rankViewButton.isSelected = !onOff
        self.myViewButton.imageView!.layer.borderWidth = 1
        self.myViewButton.imageView!.layer.cornerRadius = (self.myViewButton.imageView!.bounds.height)/2
        self.myViewButton.imageView!.layer.borderColor = color
    }
    
    
    private func buttonTapBind() {
        
        self.mainViewButton.rx.tap.flatMap { _ -> Observable<[Bool]> in
            return self.buttonflatMap(webView: self.webMainView)
        }.subscribe(onNext: { [weak self] item in
            self?.webMainView.isHidden = item[0]
            self?.webMyView.isHidden = item[1]
            self?.webRankView.isHidden = item[1]
            self?.mainViewButton.isSelected = item[0]
            self?.rankViewButton.isSelected = item[1]
            self?.myViewButton.imageView!.layer.borderWidth = 1
            self?.myViewButton.imageView!.layer.cornerRadius = (self?.myViewButton.imageView!.bounds.height)!/2
            self?.myViewButton.imageView!.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }).disposed(by: disposeBag)
        
        self.rankViewButton.rx.tap.flatMap { _ -> Observable<[Bool]> in
            return self.buttonflatMap(webView: self.webRankView)
        }.subscribe(onNext: { [weak self] item in
            self?.webRankView.isHidden = item[0]
            self?.webMyView.isHidden = item[1]
            self?.webMainView.isHidden = item[1]
            self?.mainViewButton.isSelected = item[1]
            self?.rankViewButton.isSelected = item[0]
            self?.myViewButton.imageView!.layer.borderWidth = 1
            self?.myViewButton.imageView!.layer.cornerRadius = (self?.myViewButton.imageView!.bounds.height)!/2
            self?.myViewButton.imageView!.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }).disposed(by: disposeBag)
        
        self.myViewButton.rx.tap.flatMap { _ -> Observable<[Bool]> in
            return self.buttonflatMap(webView: self.webMyView)
        }.subscribe(onNext: { [weak self] item in
            self?.webMyView.isHidden = item[0]
            self?.webMainView.isHidden = item[1]
            self?.webRankView.isHidden = item[1]
            self?.mainViewButton.isSelected = item[1]
            self?.rankViewButton.isSelected = item[1]
            self?.myViewButton.imageView!.layer.borderWidth = 1
            self?.myViewButton.imageView!.layer.cornerRadius = (self?.myViewButton.imageView!.bounds.height)!/2
            self?.myViewButton.imageView!.layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        }).disposed(by: disposeBag)
        
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
    
    private func bindWebView() {
        
        self.viewModel.loginDataBindFirstPage(.mainMainView, self.viewModel.mainViewRequestSubject)
        self.viewModel.loginDataBindFirstPage(.mainRankView, self.viewModel.rankViewRequestSubject)
        self.viewModel.loginDataBindFirstPage(.mainMyView, self.viewModel.myViewRequestSubject)
        
        self.viewModel.mainViewRequestSubject.asObservable().subscribe(onNext: { (request) in
            self.webMainView.load(request)
        }, onError: { (err) in
            print("Err \(err)")
        }).disposed(by: disposeBag)
        
        self.viewModel.rankViewRequestSubject.asObservable().subscribe(onNext: { (request) in
            self.webRankView.load(request)
        }, onError: { (err) in
            print("Err \(err)")
        }).disposed(by: disposeBag)
        
        self.viewModel.myViewRequestSubject.asObservable().subscribe(onNext: { (request) in
            self.webMyView.load(request)
        }, onError: { (err) in
            print("Err \(err)")
        }).disposed(by: disposeBag)
        
    }
    
    private func bindRx() {
        self.viewModel.loadUserImage()
        self.viewModel.userImage.asObservable().observeOn(MainScheduler.asyncInstance).subscribe(onNext: { [weak self] (image) in
            guard let img = image else { return }
            self?.myViewButton.imageEdgeInsets = UIEdgeInsets(top: 20,left: 20,bottom: 20,right: 20)
            self?.myViewButton.imageView?.contentMode = .scaleAspectFit
            let circleImg = UIImage.makeRoundImg(image: img, radius: 50)
            self?.myViewButton.imageView?.frame.size = circleImg.size
            self?.myViewButton.setImage(circleImg, for: .normal)
        }).disposed(by: disposeBag)
    }
    
    @IBAction func addNewReviewButtonTapped(_ sender: Any) {
        self.router.viewPresent("add", ["":""])
    }
    
    @objc func backButtonTapped() {
        if(self.webMainView.canGoBack && !self.webMainView.isHidden) {
            self.webMainView.goBack()
        }
        if(self.webRankView.canGoBack && !self.webRankView.isHidden) {
            self.webRankView.goBack()
        }
        if(self.webMyView.canGoBack && !self.webMyView.isHidden) {
            self.webMyView.goBack()
        }
    }
}
