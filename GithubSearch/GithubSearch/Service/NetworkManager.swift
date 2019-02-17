//
//  NetworkManager.swift
//  GithubSearch
//
//  Created by 강수진 on 17/02/2019.
//  Copyright © 2019 강수진. All rights reserved.
//

import Foundation
import Moya

struct NetworkManager : Networkable {
    
    static let sharedInstance = NetworkManager()
    
    static let githubAPIKey = ""
    let provider = MoyaProvider<GithubAPI>(plugins : [NetworkLoggerPlugin(verbose : false)])
    
    func getUserList(keyword: String, pageIdx: Int, perPage: Int, completion: @escaping (NetworkResult<(nextPageLink : String?, userList : UserSearchList)>) -> Void) {
        get(api: .githubUserList(keyword: keyword, pageIdx: pageIdx, perPage: perPage), networkData: UserSearchList.self) { (result) in
            
            func getNextPage(linkHeader : String?) -> String?{
                guard let linkHeader = linkHeader else {return nil}
                
                let links = (linkHeader).components(separatedBy: ",")
                var dictionary: [String: String] = [:]
                links.forEach({
                    let components = $0.components(separatedBy:"; ")
                    let cleanPath = components[0].trimmingCharacters(in: CharacterSet(charactersIn: " <>"))
                    dictionary[components[1]] = cleanPath
                })
                
                if let nextPagePath = dictionary["rel=\"next\""] {
                    return nextPagePath
                } else {
                    return nil
                }
            }
            
            switch result {
            case .Success(let successResult):
                let nextPageLink = getNextPage(linkHeader: successResult.resHeader?["Link"] as? String)
                completion(.Success((nextPageLink, successResult.resResult)))
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
    
    func getUserDetail(userName: String, completion: @escaping (NetworkResult<UserDetail>) -> ()) {
        get(api: .githubUserDetail(userName: userName), networkData: UserDetail.self) { (result) in
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
