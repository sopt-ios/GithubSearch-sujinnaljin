//
//  NetworkResult.swift
//  GithubSearch
//
//  Created by 강수진 on 03/02/2019.
//  Copyright © 2019 강수진. All rights reserved.
//

import Foundation

enum NetworkResult<T> {
    case Success(T)
    case Failure(Error)
}

enum Error {
    case networkConnectFail
    case networkError((resCode : Int, msg : String))
}
