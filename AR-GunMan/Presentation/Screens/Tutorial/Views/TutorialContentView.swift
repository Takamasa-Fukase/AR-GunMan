//
//  TutorialContentView.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/6/24.
//

import UIKit

final class TutorialContentView: UIView, BackgroundViewTapTrackable {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var bottomButton: UIButton!
    
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
        firstImageView.setupAnimationImages(
            imageNames: [Int](0...1).map({"howToShoot\($0)"}),
            duration: 0.8)
        secondImageView.setupAnimationImages(
            imageNames: [Int](0...1).map({"howToReload\($0)"}),
            duration: 0.8)
    }
}
