//
//  SideTableViewCell.swift
//  SoccerInfo
//
//  Created by JD_MacMini on 2021/11/23.
//

import UIKit

final class SideTableViewCell: UITableViewCell {
    @IBOutlet weak var leagueNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()        
        leagueNameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
    }
}
