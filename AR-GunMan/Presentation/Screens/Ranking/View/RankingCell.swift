//
//  RankingCell.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/12.
//

import UIKit

final class RankingCell: UITableViewCell {
    static let reuseIdentifier = "RankingCell"
    
    @IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var rankLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(ranking: Ranking, row: Int) {
        nameLabel.text = ranking.userName
        scoreLabel.text = ranking.score.scoreText
        rankLabel.text = String(row + 1)
    }
}
