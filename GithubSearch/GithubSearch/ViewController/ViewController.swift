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
    var reqUrl : String?
    var userList : [SingleUserVO] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        searchBar.delegate = self
    }
    
    func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GithubUserTVCell.reuseIdentifier) as! GithubUserTVCell
        guard userList.count > 0 else {return cell}
        cell.configure(data: userList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItemIdx = userList.count-1
        if indexPath.row == lastItemIdx {
            if let reqUrl = reqUrl {
                getUserSearchList(url: reqUrl)
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
        getUserSearchList(url: APIUrl.githubSearchUrl, params: params)
    }
}

//통신
extension ViewController {
    func getUserSearchList(url : String, params : [String : Any]? = nil){
        GithubSearchService.shareInstance.getUserList(url: url, params: params, completion: { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .networkSuccess(let userListResData):
                let userListResData = userListResData as! (nextPageLink : String?, userList : UserSearchListVO)
                if userListResData.nextPageLink != nil{
                    self.reqUrl  = userListResData.nextPageLink!
                } else {
                    self.reqUrl = nil
                }
                self.userList.append(contentsOf: userListResData.userList.items)
            case .networkFail :
                self.simpleAlert(title: "오류", message: "네트워크 상태를 확인해주세요")
            case .networkError(_, let msg):
                self.simpleAlert(title: "오류", message: msg)
            }
        })
    }
}

