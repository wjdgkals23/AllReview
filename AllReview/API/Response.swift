//
//  Response.swift
//  AllReview
//
//  Created by 정하민 on 2019/10/27.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation

struct errResponse: Codable {
    let driver: String
    let name: String
    let index: String
    let code: String
    let errmsg: String
}

struct userInfo: Codable {
    let memberGender: String
    let memberImageUrl: String
    let wantMovieIds: [String]
    let _id: String
    let joinData: String
    let memberName: String
    let platformCode: String
    let password: String
    let shortComment: String
    let memberEmail: String
    let deviceCheckId: String
    let saltSecretValue: String
    let __v: String
}

struct userSession: Codable {
    let resultCode:String
    let resultMsg:String
    let data: userInfo
    let err: errResponse
    let connectionId: String
}
