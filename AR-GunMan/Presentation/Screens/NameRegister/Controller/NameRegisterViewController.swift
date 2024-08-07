//
//  NameRegisterViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/05.
//

import UIKit
import RxSwift
import RxCocoa

final class NameRegisterViewController: UIViewController {
    var presenter: NameRegisterPresenter!
    private var contentView: NameRegisterContentView!
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
        let controllerEvents = NameRegisterPresenter.ControllerEvents(
            viewWillDisappear: rx.viewWillDisappear,
            nameTextFieldChanged: contentView.nameTextField.rx.text.orEmpty.asObservable(),
            registerButtonTapped: contentView.registerButton.rx.tap.asObservable(),
            noButtonTapped: contentView.noButton.rx.tap.asObservable(),
            backgroundViewTapped: contentView.trackBackgroundViewTap(),
            keyboardWillShowNotificationReceived: NotificationCenter.keyboardWillShow,
            keyboardWillHideNotificationReceived: NotificationCenter.keyboardWillHide
        )
        let viewModel = presenter.generateViewModel(from: controllerEvents)

        disposeBag.insert {
            viewModel.temporaryRankText
                .drive(contentView.rankLabel.rx.text)
            viewModel.temporaryRankText
                .map({ $0.isEmpty })
                .drive(contentView.rankLabelSpinner.rx.isAnimating)
            viewModel.scoreText
                .drive(contentView.scoreLabel.rx.text)
            viewModel.isRegisterButtonEnabled
                .drive(contentView.registerButton.rx.isEnabled)
            viewModel.isRegistering
                .drive(contentView.registerButton.rx.isHidden)
            viewModel.isRegistering
                .drive(contentView.registerButtonSpinner.rx.isAnimating)
            viewModel.handleActiveTextFieldOverlapWhenKeyboardWillShow
                .drive(onNext: { [weak self] notification in
                    guard let self = self,
                          let keyboardFrameEnd = notification.keyboardFrameEnd,
                          let duration = notification.keyboardAnimationDuration else { return }
                    self.view.handleActiveTextFieldOverlapWhenKeyboardWillShow(
                        keyboardFrameEnd: keyboardFrameEnd,
                        keyboardAnimationDuration: duration,
                        activeTextField: self.contentView.nameTextField
                    )
                })
            viewModel.resetActiveTextFieldPositionWhenKeyboardWillHide
                .drive(onNext: { [weak self] notification in
                    guard let self = self,
                          let duration = notification.keyboardAnimationDuration else { return }
                    self.view.resetViewTransform(with: duration)
                })
        }
    }
}
