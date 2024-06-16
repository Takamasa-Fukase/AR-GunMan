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
    var viewModel: NameRegisterViewModel!
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
        bindViewModel()
    }
    
    private func setupUI() {
        nameTextField.delegate = self
        registerButton.setTitleColor(.black.withAlphaComponent(0.1), for: .disabled)
        rankLabelSpinner.hidesWhenStopped = true
        registerButtonSpinner.hidesWhenStopped = true
    }
    
    private func bindViewModel() {
        let input = NameRegisterViewModel.Input(
            viewWillDisappear: rx.viewWillDisappear,
            nameTextFieldChanged: nameTextField.rx.text.orEmpty.asObservable(),
            registerButtonTapped: registerButton.rx.tap.asObservable(),
            noButtonTapped: noButton.rx.tap.asObservable(),
            backgroundViewTapped: trackBackgroundViewTap(),
            keyboardWillShowNotificationReceived: NotificationCenter.keyboardWillShow,
            keyboardWillHideNotificationReceived: NotificationCenter.keyboardWillHide
        )
        let output = viewModel.transform(input: input)
        let viewModelAction = output.viewModelAction
        let outputToView = output.outputToView
        
        disposeBag.insert {
            viewModelAction.rankingRegistered.subscribe()
            viewModelAction.registerCompleteEventSent.subscribe()
            viewModelAction.closeEventSent.subscribe()
            viewModelAction.viewDismissed.subscribe()
            viewModelAction.errorAlertShowed.subscribe()
            
            outputToView.temporaryRankText
                .bind(to: rankLabel.rx.text)
            outputToView.temporaryRankText
                .map({ $0.isEmpty })
                .bind(to: rankLabelSpinner.rx.isAnimating)
            outputToView.scoreText
                .bind(to: scoreLabel.rx.text)
            outputToView.isRegisterButtonEnabled
                .bind(to: registerButton.rx.isEnabled)
            outputToView.isRegistering
                .bind(to: registerButton.rx.isHidden)
            outputToView.isRegistering
                .bind(to: registerButtonSpinner.rx.isAnimating)
            outputToView.handleActiveTextFieldOverlapWhenKeyboardWillShow
                .subscribe(onNext: { [weak self] notification in
                    guard let self = self,
                          let keyboardFrameEnd = notification.keyboardFrameEnd,
                          let duration = notification.keyboardAnimationDuration else { return }
                    self.handleActiveTextFieldOverlapWhenKeyboardWillShow(
                        keyboardFrameEnd: keyboardFrameEnd,
                        keyboardAnimationDuration: duration,
                        activeTextField: self.nameTextField
                    )
                })
            outputToView.resetActiveTextFieldPositionWhenKeyboardWillHide
                .subscribe(onNext: { [weak self] notification in
                    guard let self = self,
                          let duration = notification.keyboardAnimationDuration else { return }
                    self.resetViewTransform(with: duration)
                })
        }
    }
}

extension NameRegisterViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
}
