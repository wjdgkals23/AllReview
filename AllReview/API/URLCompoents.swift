//
//  Requests.swift
//  AllReview
//
//  Created by 정하민 on 2019/10/27.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation

enum OneLineReviewError: Error {
    case makeurl(description: String)
    case parsing(description: String)
    case network(description: String)
}

struct OneLineReview { // 기본 url 셋팅
    static let scheme = "https"
    static let host = "www.teamiracle.be"
    
    static let memberRegisterPath = "/member/add"
    static let memberLoginPath = "/member/login"
}

struct OneLineReviewURLComponents {
    
    typealias api = OneLineReview
    private var com: URLComponents?
//    private var basicContent: OneLineReviewAPI = OneLineReviewAPI()
    
    init() {
        self.com = URLComponents()
        self.com?.scheme = api.scheme
        self.com?.host = api.host
    }
    
    func makeLoginURLComponents(_ userData: [String:String]) throws -> URL? {
        guard var com = self.com else { throw OneLineReviewError.makeurl(description: "URLCOMPONENTS INIT FAIL") }
        com.path = api.memberLoginPath
        com.queryItems?.removeAll()
        
        com.setQueryItems(with: userData)
        
        guard let url = com.url else { throw OneLineReviewError.makeurl(description: "URLCOMPONENTS MAKE URL FAIL") }
        
        return url
    }
}

extension URLComponents {
    mutating func setQueryItems(with parameters: [String: String]) {
        self.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
