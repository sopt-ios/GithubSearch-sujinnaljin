//
//  Networkable.swift
//  GithubSearch
//
//  Created by 강수진 on 17/02/2019.
//  Copyright © 2019 강수진. All rights reserved.
//

import Moya

protocol Networkable {
    var provider : MoyaProvider<GithubAPI>{ get }
    func getUserList(keyword: String, pageIdx: Int, perPage: Int, completion: @escaping (NetworkResult<(nextPageLink : String?, userList : UserSearchList)>) -> Void)
    func getUserDetail(userName: String, completion: @escaping (NetworkResult<UserDetail>) -> ())
    func get<T: Codable>(api : GithubAPI, networkData : T.Type, completion : @escaping (NetworkResult<(resCode : Int, resHeader : [AnyHashable : Any]?, resResult : T)>)->Void)
}

extension Networkable {
    func get<T: Codable>(api : GithubAPI, networkData : T.Type, completion : @escaping (NetworkResult<(resCode : Int, resHeader : [AnyHashable : Any]?, resResult : T)>)->Void){
        
        provider.request(api) { (result) in
            switch result {
            case let .success(res) :
                do {
                    let resCode = res.statusCode
                    let header = res.response?.allHeaderFields
                    let data = try JSONDecoder().decode(T.self, from: res.data)
                    completion(.Success((resCode, header, data)))
                } catch let err {
                    print("Decoding Err" + err.localizedDescription)
                }
            case let .failure(err) :
                if let error = err as NSError?, error.code == -1009 {
                    completion(.Failure(.networkConnectFail))
                } else {
                    let resCode = result.value?.statusCode ?? 0
                    completion(.Failure(.networkError((resCode, err.localizedDescription))))
                }
            }
        }
    }
}
