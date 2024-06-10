//
//  NameRegisterViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/05.
//

import UIKit
import RxSwift
import RxCocoa
import PKHUD

final class NameRegisterViewController: UIViewController {
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
        
        nameTextField.delegate = self
        rankLabel.text = nil
        
        let input = NameRegisterViewModel.Input(
            viewWillDisappear: rx.viewWillDisappear,
            nameTextFieldChanged: nameTextField.rx.text.orEmpty.asObservable(),
            registerButtonTapped: registerButton.rx.tap.asObservable(),
            noButtonTapped: noButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)
        
        output.rankText
            .subscribe(onNext: { [weak self] rankText in
                guard let self = self else { return }
                self.rankLabel.text = rankText
                self.rankLabelSpinner.isHidden = rankText != nil
            }).disposed(by: disposeBag)

        output.scoreText
            .bind(to: scoreLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.isRegisterButtonEnabled
            .subscribe(onNext: { [weak self] isEnabled in
                guard let self = self else { return }
                self.registerButton.isEnabled = isEnabled
                self.registerButton.setTitleColor(
                    isEnabled ? .black : .black.withAlphaComponent(0.1),
                    for: .normal
                )
            }).disposed(by: disposeBag)
        
        output.isRegistering
            .subscribe(onNext: {  [weak self] isRegistering in
                guard let self = self else { return }
                self.registerButton.isHidden = isRegistering
                self.registerButtonSpinner.isHidden = !isRegistering
                if isRegistering {
                    self.registerButtonSpinner.startAnimating()
                }
            }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification, object: nil)
            .subscribe({ [weak self] (notification) in
                guard let self = self else { return }
                if let element = notification.element {
                    self.keyboardWillShow(notification: element, textField: self.nameTextField, view: self.view)
                }
            })
        .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification, object: nil)
            .subscribe({ [weak self] (notification) in
                guard let self = self else { return }
                if let element = notification.element {
                    self.keyboardWillHide(notification: element, view: self.view)
                }
            })
        .disposed(by: disposeBag)
    }
}

extension NameRegisterViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
    
    private func keyboardWillShow(notification: Notification, textField: UIView?, view: UIView) {
        guard let rect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let activeTextField = textField else {return}
        
        let keyboardY = view.frame.size.height - rect.height
        let textYpoint = activeTextField.convert(activeTextField.frame, to: view).maxY
        let keyboardOverlap = keyboardY - textYpoint - 6
        
        print(keyboardY,textYpoint,keyboardOverlap)
        
        if keyboardOverlap < 0 {
            UIView.animate(withDuration: duration) {
                let transform = CGAffineTransform(translationX: 0, y: keyboardOverlap)
                view.transform = transform
            }
        } else {
            UIView.animate(withDuration: duration) {
                let transform = CGAffineTransform(translationX: 0, y: 0)
                view.transform = transform
            }
        }
    }
    
    private func keyboardWillHide(notification: Notification, view: UIView) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {return}
        UIView.animate(withDuration: duration) {
            view.transform = CGAffineTransform.identity
        }
    }
}
