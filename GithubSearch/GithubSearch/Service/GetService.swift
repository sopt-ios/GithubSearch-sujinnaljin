//
//  GetService.swift
//  GithubSearch
//
//  Created by 강수진 on 02/02/2019.
//  Copyright © 2019 강수진. All rights reserved.
//

import Foundation
import Alamofire

protocol GetService {
   
    func get<T: Codable>(_ URL:String, params : Parameters?, networkData : T.Type, completion : @escaping (NetworkResult<(resCode : Int, resHeader : [AnyHashable : Any]?, resResult : T)>)->Void)
}

extension GetService {
    
    func get<T: Codable>(_ URL:String, params : Parameters? = nil, networkData : T.Type, completion : @escaping (NetworkResult<(resCode : Int, resHeader : [AnyHashable : Any]?, resResult : T)>)->Void){
        
        typealias networkSuccessResult = (resCode : Int, resHeader : [AnyHashable : Any]?, resResult : T)
        guard let encodedUrl = URL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Invalid URL")
            return
        }
        
        let headers: HTTPHeaders = ["Authorization" : APIKey.GitHub.authToken]
        
        Alamofire.request(encodedUrl, method: .get, parameters: params, headers: headers)
            .validate(statusCode: 200..<300)
            .responseData {(res) in
                switch res.result {
                case .success :
                    if let value = res.result.value {
                        let decoder = JSONDecoder()
                        do {
                            let resCode = res.response?.statusCode ?? 0
                            let header = res.response?.allHeaderFields
                            let data = try decoder.decode(T.self, from: value)
                            completion(.networkSuccess((resCode, header, data)))
                        } catch{
                            print("Decoding Err")
                        }
                    }
                case .failure(let err) :
                    if let error = err as NSError?, error.code == -1009 {
                        completion(.networkFail)
                    } else {
                        let resCode = res.response?.statusCode ?? 0
                        completion(.networkError((resCode, err.localizedDescription)))
                    }
                }
        }
    }
}
