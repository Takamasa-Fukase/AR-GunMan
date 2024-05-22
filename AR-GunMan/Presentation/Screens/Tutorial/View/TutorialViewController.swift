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
        
        let horizontalPageIndexObservable = scrollView.rx.didScroll
            .map({ [weak self] _ in self?.scrollView.horizontalPageIndex ?? 0})
            .asObservable()
        
        let input = TutorialViewModel.Input(
            viewDidLoad: Observable.just(Void()),
            viewDidDisappear: rx.viewDidDisappear,
            horizontalPageIndex: horizontalPageIndexObservable,
            bottomButtonTapped: bottomButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.setupUI
            .subscribe(onNext: { [weak self] transitionType in
                guard let self = self else { return }
                self.setupUI(transitionType: transitionType)
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
