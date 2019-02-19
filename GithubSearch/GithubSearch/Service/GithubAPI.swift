//
//  GithubAPI.swift
//  GithubSearch
//
//  Created by 강수진 on 17/02/2019.
//  Copyright © 2019 강수진. All rights reserved.
//

import Foundation
import Moya

enum GithubAPI  {
    case githubUserList(keyword : String, pageIdx : Int, perPage : Int)
    case githubUserDetail(userName : String)
}

extension GithubAPI : TargetType{
    
    var baseURL: URL {
        guard let url = URL(string: "https://api.github.com") else { fatalError("base url could not be configured")}
        return url
    }
    
    var path: String {
        switch self {
        case .githubUserList(_):
            return "/search/users"
        case .githubUserDetail(let userName):
            return "/users/\(userName)"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .githubUserList(let keyword, let pageIdx, let perPage):
            let parameters : [String : Any] = ["q" : keyword,
                                               "page" : pageIdx,
                                               "per_page" : perPage]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .githubUserDetail:
            return .requestPlain
        }
    }
    
    var validationType : ValidationType {
        return .successAndRedirectCodes
    }
    
    var headers: [String : String]? {
        return ["Content-type" : "application/json",
                "Authorization" : NetworkManager.githubAPIKey]
    }
}

