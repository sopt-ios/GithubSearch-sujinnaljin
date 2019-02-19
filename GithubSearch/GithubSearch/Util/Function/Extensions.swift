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

extension UIView {
    func makeRounded(cornerRadius : CGFloat? = nil){
        if let cornerRadius_ = cornerRadius {
            self.layer.cornerRadius = cornerRadius_
        }  else {
            self.layer.cornerRadius = self.layer.frame.height/2
        }
        self.layer.masksToBounds = true
    }
}


