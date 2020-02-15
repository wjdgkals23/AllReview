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

class MainViewModel: ViewModel, WKNavigationDelegate {
    
    var mainViewRequestSubject: PublishSubject<URLRequest?> = PublishSubject<URLRequest?>()
    var rankViewRequestSubject: PublishSubject<URLRequest?> = PublishSubject<URLRequest?>()
    var myViewRequestSubject: PublishSubject<URLRequest?> = PublishSubject<URLRequest?>()
    var pushSearchViewSubject: PublishSubject<Void> = PublishSubject<Void>()
    
    var goToMyContentDetailViewSubject: PublishSubject<[String : String]> = PublishSubject<[String:String]>()
    
    var urlParseContext: ((WKWebView, WKNavigationAction, (WKNavigationActionPolicy) -> Void) -> Void)?
    
    override init(sceneCoordinator: SceneCoordinatorType) {
        super.init(sceneCoordinator: sceneCoordinator)
        
        pushSearchViewSubject.subscribe(onNext: { _ in
            let searchVM = SearchMovieViewModel(keyword: nil)
            let searchScene = Scene.search(searchVM)
            
            self.sceneCoordinator.transition(to: searchScene, using: .push, animated: false).debug().subscribe()
                .disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
    }
    
    public func loginDataBindFirstPage(_ urlTarget:OneLineReview, _ subject:PublishSubject<URLRequest?>) {
        userLoginSession.getRxLoginData()?.flatMap({ [weak self] user -> Observable<URLRequest> in
            let userData = ["memberId":user.data!._id, "userId":user.data!._id]
            let req = (self?.urlMaker.rxMakeURLRequestObservable(urlTarget, userData))!
            return req
        }).bind(to: subject)
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

extension MainViewModel: WebNavigationDelegateType {
    
    convenience init() {
        let coordinator = SceneCoordinator.init(window: UIApplication.shared.keyWindow!)
        self.init(sceneCoordinator: coordinator)
        self.urlParseContext = { [weak self] (webView: WKWebView, response: WKNavigationAction, handler: (WKNavigationActionPolicy) -> Void) -> Void in
            
            let url = response.request.url?.absoluteString
            
            if((url?.contains("https://www.teammiracle.be"))!) {
                handler(.allow)
                return
            } else {
                let index = url?.firstIndex(of: "?") ?? url?.endIndex
                let temp = String((url?[index!...])!)
                var queryDict:[String: String] = [:]
                if temp != "" {
                    queryDict = temp.parseQueryString()
                }
                    
                if((url?.contains("app://SearchMovie"))!) {
                    handler(.allow)
                    var searchKeyword: String? = nil
                    if let ind = index, ind != url!.endIndex {
                        searchKeyword = queryDict["movieNm"]
                    }
                    
                    let searchVM = SearchMovieViewModel(keyword: searchKeyword)
                    let searchScene = Scene.search(searchVM)
                    
                    self?.sceneCoordinator.transition(to: searchScene, using: .push, animated: false)
                }
                else if((url?.contains("app://MemberContents"))!) {
                    handler(.allow)
                    self!.makePageURLRequest(.showMembersContents, queryDict, (self!.mainViewRequestSubject))
                }
                else if((url?.contains("app://MyContents"))!) {
                    handler(.allow)
                    self!.makePageURLRequest(.mainMyView, queryDict, (self!.mainViewRequestSubject))
                }
                else if((url?.contains("app://ShareContent"))!) {
                    handler(.allow)
                    print(queryDict["url"]?.decodeUrl())
                }
                else if((url?.contains("app://ShareScreenshot"))!) {
                    handler(.allow)
                    let capturedImage = self?.takeScreenShot()
                    
                    let coordinator = SceneCoordinator.init(window: UIApplication.shared.keyWindow!)
                    let modalVM = ImageModalViewModel(sceneCoordinator: coordinator, image: capturedImage)
                    let modalScene = Scene.modal(modalVM)
                    self?.sceneCoordinator.transition(to: modalScene, using: .modal, animated: false).subscribe().disposed(by: self!.disposeBag)
                    
                }
                else {
                    handler(.allow)
                    return
                }
            }
        }
    }
}
