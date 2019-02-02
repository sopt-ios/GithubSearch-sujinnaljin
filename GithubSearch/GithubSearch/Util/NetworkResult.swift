//
//  NetworkResult.swift
//  GithubSearch
//
//  Created by 강수진 on 03/02/2019.
//  Copyright © 2019 강수진. All rights reserved.
//

import Foundation

enum NetworkResult<T> {
    case networkSuccess(T)
    case networkError((resCode : Int, msg : String))
    case networkFail
}
