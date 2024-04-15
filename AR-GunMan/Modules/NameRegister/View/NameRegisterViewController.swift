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

class NameRegisterViewController: UIViewController {
    //MARK: - Properties
    let disposeBag = DisposeBag()
    var viewModel: NameRegisterViewModel!
    var vmDependency: NameRegisterViewModel.Dependency!
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var rankLabelSpinner: UIActivityIndicatorView!
    @IBOutlet weak var totalScoreLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var registerButtonSpinner: UIActivityIndicatorView!
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        
        // input
        viewModel = NameRegisterViewModel(
            input: .init(viewWillDisappear: rx.viewWillDisappear,
                         nameTextFieldChanged: nameTextField.rx.text.orEmpty.asObservable(),
                         registerButtonTapped: registerButton.rx.tap.asObservable(),
                         noButtonTapped: noButton.rx.tap.asObservable()),
            dependency: vmDependency)

        // output
        viewModel.rankText
            .subscribe(onNext: { [weak self] rankText in
                guard let self = self else { return }
                self.rankLabel.text = rankText
                self.rankLabelSpinner.isHidden = rankText != nil
            }).disposed(by: disposeBag)

        viewModel.totalScore
            .map({ totalScore in
                return "Score: \(String(format: "%.3f", totalScore))"
            })
            .bind(to: totalScoreLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.isRegisterButtonEnabled
            .subscribe(onNext: { [weak self] isEnabled in
                guard let self = self else { return }
                self.registerButton.isEnabled = isEnabled
                self.registerButton.setTitleColor(
                    isEnabled ? .black : .black.withAlphaComponent(0.1),
                    for: .normal
                )
            }).disposed(by: disposeBag)
        
        viewModel.dismiss
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        viewModel.isRegistering
            .subscribe(onNext: {  [weak self] isRegistering in
                guard let self = self else { return }
                self.registerButton.isHidden = isRegistering
                self.registerButtonSpinner.isHidden = !isRegistering
                if isRegistering {
                    self.registerButtonSpinner.startAnimating()
                }
            }).disposed(by: disposeBag)
        
        viewModel.error
            .subscribe(onNext: { [weak self] element in
                guard let self = self else { return }
                self.present(UIAlertController.errorAlert(element), animated: true)
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
    
    func keyboardWillShow(notification: Notification, textField: UIView?, view: UIView) {
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
    
    func keyboardWillHide(notification: Notification, view: UIView) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {return}
        UIView.animate(withDuration: duration) {
            view.transform = CGAffineTransform.identity
        }
    }
}
