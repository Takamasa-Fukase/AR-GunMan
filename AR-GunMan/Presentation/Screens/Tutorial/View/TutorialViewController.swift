//
//  TutorialViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/23.
//

import UIKit
import RxSwift
import RxCocoa

final class TutorialViewController: UIViewController {
    var viewModel: TutorialViewModel!
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var firstImageView: UIImageView!
    @IBOutlet private weak var secondImageView: UIImageView!
    @IBOutlet private weak var thirdImageView: UIImageView!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var bottomButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let pageIndexWhenScrollViewScrolled = Observable
            .concat(
                Observable.just(0), // 初期値として0を流している
                scrollView.rx.didScroll
                    .map({ [weak self] _ in
                        guard let self = self else { return 0 }
                        return self.scrollView.horizontalPageIndex
                    })
                    .asObservable()
            )
        
        let input = TutorialViewModel.Input(
            viewDidLoad: .just(()),
            viewDidDisappear: rx.viewDidDisappear,
            pageIndexWhenScrollViewScrolled: pageIndexWhenScrollViewScrolled,
            bottomButtonTapped: bottomButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        bind(output: output)
    }
    
    private func setupUI() {
        firstImageView.setupAnimationImages(
            imageNames: [Int](0...1).map({"howToShoot\($0)"}),
            duration: 0.8)
        secondImageView.setupAnimationImages(
            imageNames: [Int](0...1).map({"howToReload\($0)"}),
            duration: 0.8)
    }
    
    private func bind(output: TutorialViewModel.Output) {
        let viewModelAction = output.viewModelAction
        let outputToView = output.outputToView
        
        disposeBag.insert {
            viewModelAction.viewDismissed.subscribe()
            viewModelAction.tutorialEndEventSent.subscribe()
            
            outputToView.setupUI
                .subscribe(onNext: { [weak self] _ in
                    self?.setupUI()
                })
            outputToView.insertBlurEffectView
                .subscribe(onNext: { [weak self] _ in
                    self?.insertBlurEffectView()
                })
            outputToView.buttonText
                .bind(to: bottomButton.rx.title(for: .normal))
            outputToView.pageControllIndex
                .bind(to: pageControl.rx.currentPage)
            outputToView.scrollToNextPage
                .subscribe(onNext: { [weak self] _ in
                    self?.scrollView.scrollHorizontallyToNextPage()
                })
        }
    }
}
