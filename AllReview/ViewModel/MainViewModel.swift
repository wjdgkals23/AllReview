//
//  MainViewModel.swift
//  AllReview
//
//  Created by 정하민 on 2019/10/31.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import WebKit

class MainViewModel: OneLineReviewViewModel {
    
    // MainViewModel은 3가지의 웹뷰를 로딩해야한다.
    // 웹뷰를 로딩하는 방식은 다음과 같이 설정한다. 예시로 mainWebView 설명
    // mainURLReqeust = mainURL(수시로 변함) + 로그인 데이터(특정 이벤트 발생(로그아웃->로그인)전 까지 불변)
    // mainURLRequest = Observable.combineLatest(mainURL, 로그인 데이터)
    // mainURL = 초기값[처음 로딩해야하는 화면에 대한 URL]을 가지고 있고, 자신이 발생한 navigation 메세지를 해석하는 구문에서 다음 URL을 받아야한다. => BehaviorSubject
    var sceneCoordinator: SceneCoordinator
    var disposeBag: DisposeBag
    
    var mainURLRequest: Observable<URLRequest>
    var rankURLRequest: Observable<URLRequest>
    var myURLRequest: Observable<URLRequest>
    
    let mainURL = Observable<OneLineReview>.just(.mainMainView)
    let rankURL = Observable<OneLineReview>.just(.mainRankView)
    let myURL = Observable<OneLineReview>.just(.mainMyView)
    
    var pushSearchViewSubject: PublishSubject<Void> = PublishSubject<Void>()
    
    var goToMyContentDetailViewSubject: PublishSubject<[String : String]> = PublishSubject<[String:String]>()
    
    var urlParseContext: ((WKWebView, WKNavigationAction, (WKNavigationActionPolicy) -> Void) -> Void)?
    
    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
        self.disposeBag = DisposeBag()
        
        mainURLRequest = Observable.combineLatest(mainURL, UserLoginSession.sharedInstance.rxloginData)
            .flatMap({ (arg) -> Observable<URLRequest> in
                let (url, userLoginData) = arg
                return OneLineReviewURL.rxMakeURLRequestObservable(url, ["memberId": userLoginData.data?._id, "userId":userLoginData.data!._id])
            })
        
        rankURLRequest = Observable.combineLatest(rankURL, UserLoginSession.sharedInstance.rxloginData)
            .flatMap({ (arg) -> Observable<URLRequest> in
                let (url, userLoginData) = arg
                return OneLineReviewURL.rxMakeURLRequestObservable(url, ["memberId": userLoginData.data?._id, "userId":userLoginData.data!._id])
            })
        
        myURLRequest = Observable.combineLatest(myURL, UserLoginSession.sharedInstance.rxloginData)
            .flatMap({ (arg) -> Observable<URLRequest> in
                let (url, userLoginData) = arg
                return OneLineReviewURL.rxMakeURLRequestObservable(url, ["memberId": userLoginData.data?._id, "userId":userLoginData.data!._id])
            })
        
        pushSearchViewSubject.subscribe(onNext: { _ in
            let searchVM = SearchMovieViewModel(keyword: nil)
            let searchScene = Scene.search(searchVM)
            
            self.sceneCoordinator.transition(to: searchScene, using: .push, animated: false).subscribe().disposed(by: self.disposeBag)
        }).disposed(by: self.disposeBag)
        
    }
    
    public func loginDataBindFirstPage(_ urlTarget:OneLineReview, _ subject:PublishSubject<URLRequest?>) {
        UserLoginSession.sharedInstance.rxloginData.flatMap({ user -> Observable<URLRequest> in
            let userData = ["memberId":user.data!._id, "userId":user.data!._id]
            let req = OneLineReviewURL.rxMakeURLRequestObservable(urlTarget, userData)
            return req
        }).debug("@@ : loginDataBindFirstPage", trimOutput: true).bind(to: subject)
            .disposed(by: disposeBag)
    }
    
    public func pushSearchView() {
        
    }
    
    public func takeScreenShot() -> UIImage? {
        var image :UIImage?
        let currentLayer = UIApplication.shared.keyWindow!.layer
        let currentScale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(currentLayer.frame.size, false, currentScale);
        guard let currentContext = UIGraphicsGetCurrentContext() else { return nil }
        currentLayer.render(in: currentContext)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let img = image else { return nil }
        return img
    }
}

//extension MainViewModel: WebNavigationDelegateType { // 바꾸자
//
//    convenience init(value:String = "") {
//        let coordinator = SceneCoordinator.init(window: UIApplication.shared.keyWindow!)
//
//        self.init(sceneCoordinator: coordinator)
//
//        self.urlParseContext = { [weak self] (webView: WKWebView, response: WKNavigationAction, handler: (WKNavigationActionPolicy) -> Void) -> Void in
//
//            let url = response.request.url?.absoluteString
//
//            if((url?.contains("https://www.teammiracle.be"))!) {
//                handler(.allow)
//                return
//            } else {
//                let index = url?.firstIndex(of: "?") ?? url?.endIndex
//                let temp = String((url?[index!...])!)
//                var queryDict:[String: String] = [:]
//                if temp != "" {
//                    queryDict = temp.parseQueryString() // queryDict가 Parse를 못하는 상황이 있을수도!!
//                }
//
//                if((url?.contains("app://SearchMovie"))!) {
//                    handler(.allow)
//                    var searchKeyword: String? = nil
//                    if let ind = index, ind != url!.endIndex {
//                        searchKeyword = queryDict["movieNm"]
//                    }
//
//                    let searchVM = SearchMovieViewModel(keyword: searchKeyword)
//                    let searchScene = Scene.search(searchVM)
//
//                    self?.sceneCoordinator.transition(to: searchScene, using: .push, animated: false)
//                }
//                else if((url?.contains("app://ShareContent"))!) {
//                    handler(.allow)
//                    print(queryDict["url"]?.decodeUrl())
//                }
//                else if((url?.contains("app://ShareScreenshot"))!) {
//                    handler(.allow)
//                    let capturedImage = self?.takeScreenShot()
//
//                    let coordinator = SceneCoordinator.init(window: UIApplication.shared.keyWindow!)
//                    let modalVM = ImageModalViewModel(sceneCoordinator: coordinator, image: capturedImage)
//                    let modalScene = Scene.modal(modalVM)
//                    self?.sceneCoordinator.transition(to: modalScene, using: .modal, animated: false).subscribe().disposed(by: self!.disposeBag)
//
//                }
//                else {
//                    handler(.allow)
//                    return
//                }
//            }
//        }
//    }
//}
//
