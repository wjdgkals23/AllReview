//
//  StringExtension.swift
//  AllReview
//
//  Created by 정하민 on 2019/11/14.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation

extension String {
    func parseQueryString() -> [String:String] {
        var temp = self
        temp.removeFirst()
        
        var returnDict = Dictionary<String,String>()
        let tempArray = temp.split(separator: "&")
        
        for item in tempArray {
            let fix = item.firstIndex(of: "=")
            let beforeFix = item.index(before: fix!)
            let afterFix = item.index(after: fix!)
            let startIndex = item.startIndex
            let endIndex = item.endIndex
            
            let key = item[startIndex...beforeFix]
            let value = item[afterFix..<endIndex]
            
            returnDict[String(key)] = String(value)
        }
        
        return returnDict
    }
    
    func encodeUrl() -> String?
    {
        return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    }
    func decodeUrl() -> String?
    {
        return self.removingPercentEncoding
    }
}
