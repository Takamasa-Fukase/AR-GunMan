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
    var presenter: TutorialPresenter!
    private var contentView: TutorialContentView!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setView()
        bind()
    }
    
    private func setView() {
        contentView = .init(frame: view.frame)
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

        let controllerEvents = TutorialPresenter.ControllerEvents(
            viewDidLoad: .just(()),
            viewDidDisappear: rx.viewDidDisappear,
            pageIndexWhenScrollViewScrolled: pageIndexWhenScrollViewScrolled,
            bottomButtonTapped: contentView.bottomButton.rx.tap.asObservable(),
            backgroundViewTapped: contentView.trackBackgroundViewTap()
        )
        let viewModel = presenter.generateViewModel(from: controllerEvents)

        disposeBag.insert {
            viewModel.insertBlurEffectView
                .drive(onNext: { [weak self] _ in
                    self?.view.insertBlurEffectView()
                })
            viewModel.buttonText
                .drive(contentView.bottomButton.rx.title(for: .normal))
            viewModel.pageControlIndex
                .drive(contentView.pageControl.rx.currentPage)
            viewModel.scrollToNextPage
                .drive(onNext: { [weak self] _ in
                    self?.contentView.scrollView.scrollHorizontallyToNextPage()
                })
        }
    }
}
