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

        scrollView.delegate = self
        pageControl.isUserInteractionEnabled = false
        
        animateFirstImageView()
        animateSecondImageView()
        
        if transitionType == .gamePage {
            setupBlurEffect()
        }
        
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
                if self.transitionType == .gamePage {
                    UserDefaultsUtil.setTutorialSeen()
                }
                self.delegate?.tutorialEnded()
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
    
    private func setupBlurEffect() {
        //背景をぼかし処理
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = self.view.frame
        self.view.insertSubview(visualEffectView, at: 0)
    }
    
    private func getCurrentScrollViewIndex() -> Int {
        let contentsOffSetX: CGFloat = scrollView.contentOffset.x
        let pageIndex = Int(round(contentsOffSetX / scrollView.frame.width))
        return pageIndex
    }
    
    private func animateFirstImageView() {
        let images = [UIImage(named: "howToShoot0")!, UIImage(named: "howToShoot1")!]
        firstImageView.animationImages = images
        firstImageView.animationDuration = 0.8
        firstImageView.animationRepeatCount = 0
        firstImageView.startAnimating()
    }
    
    private func animateSecondImageView() {
        let images = [UIImage(named: "howToReload0")!, UIImage(named: "howToReload1")!]
        secondImageView.animationImages = images
        secondImageView.animationDuration = 0.8
        secondImageView.animationRepeatCount = 0
        secondImageView.startAnimating()
    }
    
}

extension TutorialViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        viewModel.currentScrollViewIndex.onNext(getCurrentScrollViewIndex())
    }
    
}
