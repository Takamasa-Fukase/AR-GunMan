//
//  TutorialViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/23.
//

import UIKit
import RxSwift
import RxCocoa

protocol TutorialVCDelegate: AnyObject {
    func tutorialEnded()
}

class TutorialViewController: UIViewController {
    
    enum TransitType {
        case topPage
        case gamePage
    }
    
    //MARK: - Properties
    let viewModel = TutorialViewModel()
    let disposeBag = DisposeBag()
    var transitionType: TransitType = .topPage
    weak var delegate: TutorialVCDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var bottomButton: UIButton!
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //input
        let _ = bottomButton.rx.tap
            .bind(to: viewModel.bottomButtonTapped)
            .disposed(by: disposeBag)
        
        //output
        let _ = viewModel.pageControlValue
            .bind(to: pageControl.rx.currentPage)
            .disposed(by: disposeBag)
        
        let _ = viewModel.buttonText
            .bind(to: bottomButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        let _ = viewModel.scrollPage
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                guard !self.scrollView.isDecelerating else {return}
                let frameWidth = self.scrollView.frame.width
                let targetContentOffsetX = frameWidth * CGFloat(min(self.getCurrentScrollViewIndex() + 1, 2))
                let targetCGPoint = CGPoint(x: targetContentOffsetX, y: 0)
                self.scrollView.setContentOffset(targetCGPoint, animated: true)
            }).disposed(by: disposeBag)
        
        let _ = viewModel.dismiss
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UserDefaults.isTutorialAlreadySeen = transitionType == .gamePage
        self.delegate?.tutorialEnded()
        
        setupUI()
    }
    
    private func setupUI() {
        if viewModel.transitionType == .gamePage {
            insertBlurEffectView()
        }
        firstImageView.setupAnimationImages(
            imageNames: [Int](0...1).map({"howToShoot\($0)"}),
            duration: 0.8)
        secondImageView.setupAnimationImages(
            imageNames: [Int](0...1).map({"howToReload\($0)"}),
            duration: 0.8)
    }
}
