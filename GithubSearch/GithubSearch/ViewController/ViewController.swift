//
//  ViewController.swift
//  GithubSearch
//
//  Created by 강수진 on 02/02/2019.
//  Copyright © 2019 강수진. All rights reserved.
//

import UIKit

class ViewController: UIViewController{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var networkProvider = NetworkManager.sharedInstance
    var nextUrl : (keyword : String, pageIdx : Int, perPage : Int)?
    var userList : [SingleUser] = []
    let searchUserDetailGroup = DispatchGroup()
    let indicatorView = UIActivityIndicatorView(style: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        searchBar.delegate = self
        indicatorView.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
    }
    
    func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = indicatorView
    }
    
    func stopIndicatorAnimating(){
        self.indicatorView.stopAnimating()
        tableView.tableFooterView?.isHidden = true
    }
    
    func startIndicatorAnimating(){
        tableView.tableFooterView?.isHidden = false
        indicatorView.startAnimating()
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.cell(for: GithubUserTVCell.self)
        guard userList.count > 0 else {return cell}
        cell.configure(data: userList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let lastItemIdx = userList.count-1
        
        if indexPath.row == lastItemIdx && !indicatorView.isAnimating  {
            if let nextUrl = nextUrl {
                searchGithubUser(keyword: nextUrl.keyword, pageIdx: nextUrl.pageIdx, perPage: nextUrl.perPage)
            }
        }
    }
}

extension ViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.searchUser(_:)), object: searchBar)
        perform(#selector(self.searchUser(_:)), with: searchBar, afterDelay: 0.5)
    }
    
    @objc func searchUser(_ searchBar: UISearchBar) {
        self.userList = []
        guard let query = searchBar.text, query.trimmingCharacters(in: .whitespaces) != "" else {
            return
        }
        searchGithubUser(keyword: query, pageIdx: 1, perPage: 20)
    }
    
    func searchGithubUser(keyword : String, pageIdx : Int, perPage: Int){
        startIndicatorAnimating()
        
        getUserSearchList(keyword: keyword, pageIdx: pageIdx, perPage: perPage) { [weak self] (userSearchList) in
            guard let `self` = self else { return }
            userSearchList.forEach({ (user) in
                self.searchUserDetailGroup.enter()
                self.getUserRepoCnt(userName: user.login) { (result) in
                    switch result {
                    case .Success(let repoCnt) :
                        var tempUser = user
                        tempUser.pulicRepoCnt = repoCnt
                        self.userList.append(tempUser)
                    case .Failure(let errorType) :
                        self.showErrorAlert(errorType: errorType)
                    }
                    self.searchUserDetailGroup.leave()
                }
            })
            
            self.searchUserDetailGroup.notify(queue: .main) {
                self.stopIndicatorAnimating()
                self.tableView.reloadData()
            }
        }
    }
}

extension ViewController {
    
    func getUserSearchList(keyword : String, pageIdx : Int, perPage : Int, completion: @escaping ([SingleUser]) -> Void){
        networkProvider.getUserList(keyword: keyword, pageIdx: pageIdx, perPage: perPage) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .Success(let userListResData):
                let userListResData = userListResData
                if userListResData.nextPageLink != nil{
                    if let nextParams = self.getQueryStringParameter(url: userListResData.nextPageLink!) {
                        self.nextUrl  = (nextParams.keyword, nextParams.pageIdx, nextParams.perPage)
                    } else {
                        self.nextUrl = nil
                    }
                } else {
                    self.nextUrl = nil
                }
                completion(userListResData.userList.items)
            case .Failure(let errorType) :
                self.stopIndicatorAnimating()
                self.showErrorAlert(errorType: errorType)
            }
        }
    }
    
    
    func getUserRepoCnt(userName : String, completion: @escaping (NetworkResult<Int>) -> Void){
        networkProvider.getUserDetail(userName: userName) { (result) in
            switch result {
            case .Success(let userDetail):
                let userDetail = userDetail
                completion(.Success(userDetail.publicRepos))
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
    
    func getQueryStringParameter(url: String) -> (keyword : String, pageIdx : Int, perPage : Int)? {
        guard let url = URLComponents(string: url), let queryItems = url.queryItems else {return nil}
        let result = queryItems.reduce([String : Any](), { (result, item) in
            var res = result
            switch item.name {
            case "q" :
                res["keyword"] = item.value
            case "page" :
                res["pageIdx"] = Int(item.value ?? "")
            case "per_page" :
                res["perPage"] = Int(item.value ?? "")
            default :
                break
            }
            return res
        })
        
        guard let keyword = result["keyword"], let pageIdx = result["pageIdx"], let perPage = result["perPage"] else {return nil}
        
        return (keyword, pageIdx, perPage) as? (keyword: String, pageIdx: Int, perPage: Int)
    }
}

