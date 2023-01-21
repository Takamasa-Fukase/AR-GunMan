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
    var vmDependency: TutorialViewModel.Dependency!
    
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
        viewModel = TutorialViewModel(
            input: .init(viewDidDisappear: rx.viewDidDisappear,
                         horizontalPageIndex: horizontalPageIndexObservable,
                         bottomButtonTapped: bottomButton.rx.tap.asObservable()),
            dependency: vmDependency)
        
        // MARK: - output
        viewModel.buttonText
            .bind(to: bottomButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        viewModel.pageControllIndex
            .bind(to: pageControl.rx.currentPage)
            .disposed(by: disposeBag)
        
        viewModel.scrollToNextPage
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.scrollView.scrollHorizontallyToNextPage()
            }).disposed(by: disposeBag)
        
        viewModel.dismiss
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
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
