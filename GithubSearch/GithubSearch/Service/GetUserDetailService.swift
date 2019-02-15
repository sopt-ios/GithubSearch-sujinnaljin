//
//  GetUserDetailService.swift
//  GithubSearch
//
//  Created by 강수진 on 04/02/2019.
//  Copyright © 2019 강수진. All rights reserved.
//

import Foundation

struct GetUserDetailService : GetService {
    static let shareInstance = GetUserDetailService()
    
    func getUserDetail(url : String, params : [String : Any]? = nil, completion : @escaping (NetworkResult<Any>) -> Void) {
        get(url, params: params, networkData: UserDetail.self) { (result) in
            switch result {
            case .Success(let successResult):
                completion(.Success((successResult.resResult)))
            case .Failure(let errorType) :
                switch errorType {
                case .networkConnectFail:
                    completion(.Failure(.networkConnectFail))
                case .networkError(let resCode, let msg):
                    completion(.Failure(.networkError((resCode, msg))))
                }
            }
        }
    }
}

