//
//  ShowAlert.swift
//  GithubSearch
//
//  Created by 강수진 on 15/02/2019.
//  Copyright © 2019 강수진. All rights reserved.
//

import UIKit

extension UIViewController {
    func simpleAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okTitle = "확인"
        let okAction = UIAlertAction(title: okTitle,style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    func showErrorAlert(errorType : Error){
        switch errorType {
        case .networkConnectFail:
            self.simpleAlert(title: "오류", message: "네트워크 상태를 확인해주세요")
        case .networkError(_, let msg):
            self.simpleAlert(title: "오류", message: msg)
        }
    }
}
