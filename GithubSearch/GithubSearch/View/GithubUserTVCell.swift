//
//  GithubUserTVCell.swift
//  GithubSearch
//
//  Created by 강수진 on 02/02/2019.
//  Copyright © 2019 강수진. All rights reserved.
//

import UIKit
import Kingfisher

class GithubUserTVCell: UITableViewCell {
    
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var repoCntLbl: UILabel!
    
    func configure(data : SingleUserVO){
        nameLbl.text = data.login
        profileImgView.kf.setImage(with: URL(string: data.avatarURL))
    }
}
