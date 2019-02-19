//
//  CellTypeCast.swift
//  GithubSearch
//
//  Created by 강수진 on 14/02/2019.
//  Copyright © 2019 강수진. All rights reserved.
//

import UIKit
extension UITableView {
    func cell<T: UITableViewCell>(for cellType: T.Type) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: T.reuseIdentifier) as? T else {
            fatalError("Could not find cell with reuseID \(T.reuseIdentifier)")
        }
        return cell
    }
}
