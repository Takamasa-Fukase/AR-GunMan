//
//  RankingCell.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/12.
//

import UIKit

class RankingCell: UITableViewCell {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell(ranking: Ranking, row: Int) {
        nameLabel.text = ranking.userName
        scoreLabel.text = String(ranking.score)
        rankLabel.text = String(row + 1)
    }
}
