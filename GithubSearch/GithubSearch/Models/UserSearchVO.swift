//
//  UserSearchVO.swift
//  GithubSearch
//
//  Created by 강수진 on 02/02/2019.
//  Copyright © 2019 강수진. All rights reserved.
//

import Foundation

struct UserSearchListVO: Codable {
    let incompleteResults: Bool
    let items: [SingleUserVO]
    
    enum CodingKeys: String, CodingKey {
        case incompleteResults = "incomplete_results"
        case items
    }
}

struct SingleUserVO: Codable {
    let login: String
    let avatarURL: String
   
    enum CodingKeys: String, CodingKey {
        case login
        case avatarURL = "avatar_url"
    }
}

struct UserDetailVO: Codable {
    let publicRepos : String
    
    enum CodingKeys: String, CodingKey {
        case publicRepos = "public_repos"
    }
}
