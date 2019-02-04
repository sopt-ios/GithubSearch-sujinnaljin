//
//  GetUserDetailService.swift
//  GithubSearch
//
//  Created by 강수진 on 04/02/2019.
//  Copyright © 2019 강수진. All rights reserved.
//

import Foundation

struct GetUserDetailService : GetService {
    
    typealias NetworkData = UserDetailVO
    static let shareInstance = GetUserDetailService()
    
    func getUserDetail(url : String, params : [String : Any]? = nil, completion : @escaping (NetworkResult<Any>) -> Void) {
        get(url, params: params) { (result) in
            switch result {
            case .networkSuccess(let successResult):
                completion(.networkSuccess((successResult.resResult)))
            case .networkError(let errResult):
                completion(.networkError((errResult.resCode, errResult.msg)))
            case .networkFail:
                completion(.networkFail)
            }
        }
    }
}

