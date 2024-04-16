//
//  TutorialViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/23.
//

import UIKit
import RxSwift
import RxCocoa

class TutorialViewController: UIViewController {
    var viewModel: TutorialViewModel!
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var bottomButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - input
        let horizontalPageIndexObservable = scrollView.rx.didScroll
            .map({_ in self.scrollView.horizontalPageIndex})
            .asObservable()
        let input = TutorialViewModel.Input(
            viewDidLoad: Observable.just(Void()),
            viewDidDisappear: rx.viewDidDisappear,
            horizontalPageIndex: horizontalPageIndexObservable,
            bottomButtonTapped: bottomButton.rx.tap.asObservable()
        )
        
        // MARK: - output
        let output = viewModel.transform(input: input)
        
        output.setupUI
            .subscribe(onNext: { [weak self] transitionType in
                guard let self = self else { return }
                setupUI(transitionType: transitionType)
            }).disposed(by: disposeBag)
        
        output.buttonText
            .bind(to: bottomButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        output.pageControllIndex
            .bind(to: pageControl.rx.currentPage)
            .disposed(by: disposeBag)
        
        output.scrollToNextPage
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.scrollView.scrollHorizontallyToNextPage()
            }).disposed(by: disposeBag)
    }
    
    private func setupUI(transitionType: TutorialViewModel.TransitType) {
        if transitionType == .gamePage {
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
