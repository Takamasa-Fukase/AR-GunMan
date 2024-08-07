//
//  TopContentView.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import UIKit

final class TopContentView: UIView {
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var startButtonIcon: UIImageView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var settingsButtonIcon: UIImageView!
    @IBOutlet weak var howToPlayButton: UIButton!
    @IBOutlet weak var howToPlayButtonIcon: UIImageView!
    
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
    }
}
