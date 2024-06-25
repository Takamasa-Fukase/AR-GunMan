//
//  TutorialViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/23.
//

import UIKit
import RxSwift
import RxCocoa

final class TutorialViewController: UIViewController, BackgroundViewTapTrackable {
    var presenter: TutorialPresenterInterface!
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var firstImageView: UIImageView!
    @IBOutlet private weak var secondImageView: UIImageView!
    @IBOutlet private weak var thirdImageView: UIImageView!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var bottomButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bind()
    }
    
    private func setupUI() {
        firstImageView.setupAnimationImages(
            imageNames: [Int](0...1).map({"howToShoot\($0)"}),
            duration: 0.8)
        secondImageView.setupAnimationImages(
            imageNames: [Int](0...1).map({"howToReload\($0)"}),
            duration: 0.8)
    }
    
    private func bind() {
        let pageIndexWhenScrollViewScrolled = scrollView.rx.didScroll
            .map({ [weak self] _ in
                guard let self = self else { return 0 }
                return self.scrollView.horizontalPageIndex
            })
            .startWith(0) // 初期値として0を流している
            .asObservable()

        let controllerInput = TutorialControllerInput(
            viewDidLoad: .just(()),
            viewDidDisappear: rx.viewDidDisappear,
            pageIndexWhenScrollViewScrolled: pageIndexWhenScrollViewScrolled,
            bottomButtonTapped: bottomButton.rx.tap.asObservable(),
            backgroundViewTapped: trackBackgroundViewTap()
        )
        let viewModel = presenter.transform(input: controllerInput)
        
        disposeBag.insert {
            viewModel.insertBlurEffectView
                .subscribe(onNext: { [weak self] _ in
                    self?.insertBlurEffectView()
                })
            viewModel.buttonText
                .bind(to: bottomButton.rx.title(for: .normal))
            viewModel.pageControlIndex
                .bind(to: pageControl.rx.currentPage)
            viewModel.scrollToNextPage
                .subscribe(onNext: { [weak self] _ in
                    self?.scrollView.scrollHorizontallyToNextPage()
                })
        }
    }
}
