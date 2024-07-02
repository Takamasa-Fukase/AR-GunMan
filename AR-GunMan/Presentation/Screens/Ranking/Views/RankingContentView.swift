//
//  RankingContentView.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/6/24.
//

import UIKit

final class RankingContentView: UIView, BackgroundViewTapTrackable {
    let rankingListView = RankingListView()

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var rankingListBaseView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        loadNib()
        setupUI()
    }
    
    private func setupUI() {
        rankingListBaseView.addSubview(rankingListView)
        rankingListBaseView.addConstraints(for: rankingListView)
    }
}
