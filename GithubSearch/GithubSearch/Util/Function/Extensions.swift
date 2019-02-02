//
//  Extensions.swift
//  GithubSearch
//
//  Created by 강수진 on 02/02/2019.
//  Copyright © 2019 강수진. All rights reserved.
//

import UIKit

extension NSObject {
    static var reuseIdentifier:String {
        return String(describing:self)
    }
}

extension UIViewController {
    func simpleAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okTitle = "확인"
        let okAction = UIAlertAction(title: okTitle,style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}


