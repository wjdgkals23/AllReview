//
//  RxRequests.swift
//  AllReview
//
//  Created by 정하민 on 2019/10/27.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

//URLSession

typealias err = OneLineReviewError

class OneLineReviewAPI {
    
    static let sharedInstance = OneLineReviewAPI()

    private var disaposable = DisposeBag()
    
    private let decoder = JSONDecoder()
    private let urlMaker = OneLineReviewURL()
    
    init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
    }
    
    func rxTestLogin(userData: [String:String]) -> Observable<userLoginSession> {
        self.urlMaker.rxMakeLoginURLComponents(OneLineReview.login, userData).flatMap { urlRequest -> Observable<userLoginSession> in
            let dataTask = URLSession.shared.rx.response(request: urlRequest)
            return dataTask
                .debug("testLoginRequest")
                .flatMap { (response: HTTPURLResponse, data: Data) -> Observable<userLoginSession> in
                    if 200 ..< 300 ~= response.statusCode {
                        do {
                            let userSessionData = try self.decoder.decode(userLoginSession.self, from: data)
                            return Observable.create { observer -> Disposable in
                                observer.on(.next(userSessionData))
                                return Disposables.create()
                            }
                        } catch {
                            return Observable.error(err.parsing(description: "RESPONSE PARSE ERROR \(error)"))
                        }
                    }
                    else {
                        return Observable.error(err.network(description: "NETWORK ERROR"))
                    }
                }
        }
    }

}

