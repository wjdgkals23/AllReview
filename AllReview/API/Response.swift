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

struct successResponse: Codable {
    
}

struct userInfo: Codable {
    let memberGender: String
    let memberImageUrl: String
    let wantMovieIds: [String]
    let _id: String
    let joinDate: String
    let memberName: String
    let platformCode: String
    let password: String
    let shortComment: String
    let memberEmail: String
    let deviceCheckId: String
    let saltSecretValue: String
    let __v: String
}

struct loginInfo: Codable {
    let memberGender: String
    let memberImageUrl: String
    let wantMovieIds: Array<String>?
    let _id: String
    let joinDate: String
    let memberName: String
    let platformCode: String
    let password: String
    let shortComment: String
    let memberEmail: String
    let deviceCheckId: String
}
//"memberGender": "M",
//"memberImageUrl": "https://www.google.com/url?sa=i&source=images&cd=&ved=2ahUKEwiby6WepqnjAhUBwbwKHRxiCCQQjRx6BAgBEAU&url=https%3A%2F%2Ftvtropes.org%2Fpmwiki%2Fpmwiki.php%2FMain%2FGenres&psig=AOvVaw1QJx4SFWfHKqjgTD2onVo8&ust=1562811922956472",
//"wantMovieIds": [],
//"_id": "5d25b1a9b692d8fa466e8a75",
//"joinDate": "2019-07-10T09:36:41.918Z",
//"memberName": "veyond",
//"platformCode": "EM",
//"password": "$2a$10$2qcAkfDa8NFy3QB/Z5doH.7E2htza4.PD0NOsB3LEZA1Ei5mXC1aG",
//"shortComment": "Mystery",
//"memberEmail": "shjo@naver.com",
//"deviceCheckId": "macos-yond"

struct userLoginSession: Codable {
    let resultCode:String
    let resultMsg:String
    let data:loginInfo
    let err:successResponse
    let connectionId:String
}

struct userInitSession: Codable {
    let resultCode:String
    let resultMsg:String
    let data:userInfo
    let err:errResponse
    let connectionId:String
}


//{
//  "resultCode": "0000",
//  "resultMsg": "password is correct",
//  "data": {
//    "memberGender": "M",
//    "memberImageUrl": "https://www.google.com/url?sa=i&source=images&cd=&ved=2ahUKEwiby6WepqnjAhUBwbwKHRxiCCQQjRx6BAgBEAU&url=https%3A%2F%2Ftvtropes.org%2Fpmwiki%2Fpmwiki.php%2FMain%2FGenres&psig=AOvVaw1QJx4SFWfHKqjgTD2onVo8&ust=1562811922956472",
//    "wantMovieIds": [],
//    "_id": "5d25b1a9b692d8fa466e8a75",
//    "joinDate": "2019-07-10T09:36:41.918Z",
//    "memberName": "veyond",
//    "platformCode": "EM",
//    "password": "$2a$10$2qcAkfDa8NFy3QB/Z5doH.7E2htza4.PD0NOsB3LEZA1Ei5mXC1aG",
//    "shortComment": "Mystery",
//    "memberEmail": "shjo@naver.com",
//    "deviceCheckId": "macos-yond"
//  },
//  "err": {},
//  "connectionId": "201910280357567914738757"
//}
