//
//  UserSearch.swift
//  GithubSearch
//
//  Created by 강수진 on 02/02/2019.
//  Copyright © 2019 강수진. All rights reserved.
//

import Foundation

struct UserSearchList: Codable {
    let incompleteResults: Bool
    let items: [SingleUser]
    
    enum CodingKeys: String, CodingKey {
        case incompleteResults = "incomplete_results"
        case items
    }
}

struct SingleUser: Codable {
    let login: String
    let avatarURL: String
    var pulicRepoCnt : Int = 0
   
    enum CodingKeys: String, CodingKey {
        case login
        case avatarURL = "avatar_url"
    }
}

struct UserDetail: Codable {
    let publicRepos : Int
    
    enum CodingKeys: String, CodingKey {
        case publicRepos = "public_repos"
    }
}
