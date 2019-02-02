//
//  APIUrl.swift
//  GithubSearch
//
//  Created by 강수진 on 03/02/2019.
//  Copyright © 2019 강수진. All rights reserved.
//

import Foundation

struct APIUrl {
    
    private struct Domains {
        static let github = "https://api.github.com"
    }
    
    private struct Routes {
        static let users = "/users"
        static let search = "/search/users"
    }
    
    private static let gitHubDomain = Domains.github
    
    static let githubSearchUrl = gitHubDomain + Routes.search
    static let githubUsersUrl = gitHubDomain + Routes.users
    
}
