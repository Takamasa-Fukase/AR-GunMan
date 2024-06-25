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
    var presenter: TutorialPresenterInterface!
    private let contentView = TutorialContentView()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setView()
        bind()
    }
    
    private func setView() {
        view.addSubview(contentView)
        view.addConstraints(for: contentView)
    }
    
    private func bind() {
        let pageIndexWhenScrollViewScrolled = contentView.scrollView.rx.didScroll
            .map({ [weak self] _ in
                guard let self = self else { return 0 }
                return self.contentView.scrollView.horizontalPageIndex
            })
            .startWith(0) // 初期値として0を流している
            .asObservable()

        let controllerInput = TutorialControllerInput(
            viewDidLoad: .just(()),
            viewDidDisappear: rx.viewDidDisappear,
            pageIndexWhenScrollViewScrolled: pageIndexWhenScrollViewScrolled,
            bottomButtonTapped: contentView.bottomButton.rx.tap.asObservable(),
            backgroundViewTapped: contentView.trackBackgroundViewTap()
        )
        let viewModel = presenter.transform(input: controllerInput)
        
        disposeBag.insert {
            viewModel.insertBlurEffectView
                .subscribe(onNext: { [weak self] _ in
                    self?.insertBlurEffectView()
                })
            viewModel.buttonText
                .bind(to: contentView.bottomButton.rx.title(for: .normal))
            viewModel.pageControlIndex
                .bind(to: contentView.pageControl.rx.currentPage)
            viewModel.scrollToNextPage
                .subscribe(onNext: { [weak self] _ in
                    self?.contentView.scrollView.scrollHorizontallyToNextPage()
                })
        }
    }
}
