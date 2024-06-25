//
//  NameRegisterViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/05.
//

import UIKit
import RxSwift
import RxCocoa

final class NameRegisterViewController: UIViewController, BackgroundViewTapTrackable {
    var presenter: NameRegisterPresenterInterface!
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var rankLabel: UILabel!
    @IBOutlet private weak var rankLabelSpinner: UIActivityIndicatorView!
    @IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var registerButton: UIButton!
    @IBOutlet private weak var registerButtonSpinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
    }
    
    private func setupUI() {
        nameTextField.delegate = self
        registerButton.setTitleColor(.black.withAlphaComponent(0.1), for: .disabled)
        rankLabelSpinner.hidesWhenStopped = true
        registerButtonSpinner.hidesWhenStopped = true
    }
    
    private func bind() {
        let controllerInput = NameRegisterControllerInput(
            viewWillDisappear: rx.viewWillDisappear,
            nameTextFieldChanged: nameTextField.rx.text.orEmpty.asObservable(),
            registerButtonTapped: registerButton.rx.tap.asObservable(),
            noButtonTapped: noButton.rx.tap.asObservable(),
            backgroundViewTapped: trackBackgroundViewTap(),
            keyboardWillShowNotificationReceived: NotificationCenter.keyboardWillShow,
            keyboardWillHideNotificationReceived: NotificationCenter.keyboardWillHide
        )
        let viewModel = presenter.transform(input: controllerInput)
        
        disposeBag.insert {
            viewModel.temporaryRankText
                .bind(to: rankLabel.rx.text)
            viewModel.temporaryRankText
                .map({ $0.isEmpty })
                .bind(to: rankLabelSpinner.rx.isAnimating)
            viewModel.scoreText
                .bind(to: scoreLabel.rx.text)
            viewModel.isRegisterButtonEnabled
                .bind(to: registerButton.rx.isEnabled)
            viewModel.isRegistering
                .bind(to: registerButton.rx.isHidden)
            viewModel.isRegistering
                .bind(to: registerButtonSpinner.rx.isAnimating)
            viewModel.handleActiveTextFieldOverlapWhenKeyboardWillShow
                .subscribe(onNext: { [weak self] notification in
                    guard let self = self,
                          let keyboardFrameEnd = notification.keyboardFrameEnd,
                          let duration = notification.keyboardAnimationDuration else { return }
                    self.view.handleActiveTextFieldOverlapWhenKeyboardWillShow(
                        keyboardFrameEnd: keyboardFrameEnd,
                        keyboardAnimationDuration: duration,
                        activeTextField: self.nameTextField
                    )
                })
            viewModel.resetActiveTextFieldPositionWhenKeyboardWillHide
                .subscribe(onNext: { [weak self] notification in
                    guard let self = self,
                          let duration = notification.keyboardAnimationDuration else { return }
                    self.view.resetViewTransform(with: duration)
                })
        }
    }
}

extension NameRegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
}
