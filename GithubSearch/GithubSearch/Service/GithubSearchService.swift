//
//  GithubSearchService.swift
//  GithubSearch
//
//  Created by 강수진 on 02/02/2019.
//  Copyright © 2019 강수진. All rights reserved.
//

import Foundation

struct GithubSearchService : GetService {
    
    typealias NetworkData = UserSearchListVO
    static let shareInstance = GithubSearchService()
    
    func getUserList(url : String, params : [String : Any]? = nil, completion : @escaping (NetworkResult<Any>) -> Void) {
        get(url, params: params) { (result) in
            
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
            case .networkSuccess(let successResult):
                let nextPageLink = getNextPage(linkHeader: successResult.resHeader?["Link"] as? String)
                completion(.networkSuccess((nextPageLink, successResult.resResult)))
            case .networkError(let errResult):
                completion(.networkError((errResult.resCode, errResult.msg)))
            case .networkFail:
                completion(.networkFail)
            }
        }
    }
}
