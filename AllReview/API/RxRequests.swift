//
//  RxRequests.swift
//  AllReview
//
//  Created by 정하민 on 2019/10/27.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import RxSwift

//URLSession

class OneLineReviewAPI {
    
    static let shared = OneLineReviewAPI()
    let session: URLSession = URLSession(configuration: .default)

    func rxTestLogin(userData: [String:String], completed: @escaping (Data?, URLResponse?, Error?) -> Void) throws -> Observable<userSession?> {
        return Observable.create { seal in
            do {
                let comMaker = OneLineReviewURLComponents()
                guard let url = try comMaker.makeLoginURLComponents(userData) else { throw OneLineReviewError.makeurl(description: "TEST URL UNWRAPPED FAIL") }
                DispatchQueue.global().async {
                    self.session.dataTask(with: url, completionHandler: completed)
                }
            } catch {
                
            }
            return Disposables.create()
        }
    }
    
}

