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
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    var reqUrl : String?
    var userList : [SingleUser] = []
    let searchUserDetailGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        self.indicatorView.isHidden = true
        searchBar.delegate = self
    }
    
    func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func stopIndicatorAnimating(){
        self.indicatorView.stopAnimating()
        self.indicatorView.isHidden = true
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
        if indexPath.row == lastItemIdx {
            if let reqUrl = reqUrl {
                searchGithubUser(url: reqUrl)
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
        let params : [String : Any] = ["q":query,
                                       "page":1,
                                       "per_page":20]
        searchGithubUser(url: APIUrl.githubSearchUrl, params: params)
    }
    
    func searchGithubUser(url : String, params : [String : Any]? = nil){
        self.indicatorView.isHidden = false
        indicatorView.startAnimating()
        
        getUserSearchList(url: url, params: params) { [weak self] (userSearchList) in
            guard let `self` = self else { return }
            userSearchList.forEach({ (user) in
                self.searchUserDetailGroup.enter()
                self.getUserRepoCnt(url: APIUrl.githubUsersUrl+"/"+user.login){ result in
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

//통신
extension ViewController {
    func getUserSearchList(url : String, params : [String : Any]? = nil, completion: @escaping ([SingleUser]) -> Void){
        GithubSearchService.shareInstance.getUserList(url: url, params: params, completion: { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .Success(let userListResData):
                let userListResData = userListResData
                if userListResData.nextPageLink != nil{
                    self.reqUrl  = userListResData.nextPageLink!
                } else {
                    self.reqUrl = nil
                }
                completion(userListResData.userList.items)
            case .Failure(let errorType) :
                self.stopIndicatorAnimating()
                self.showErrorAlert(errorType: errorType)
            }
        })
    }
    
    
    func getUserRepoCnt(url : String, completion: @escaping (NetworkResult<Int>) -> Void){
        GetUserDetailService.shareInstance.getUserDetail(url: url,completion: { (result) in
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
        })
    }
}

