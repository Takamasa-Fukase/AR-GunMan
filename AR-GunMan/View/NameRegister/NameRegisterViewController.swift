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
    
    @IBOutlet weak var displayRankLabel: UILabel!
    @IBOutlet weak var totalScoreLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        
        // input
        viewModel = NameRegisterViewModel(
            input: .init(nameTextFieldChanged: nameTextField.rx.text.orEmpty.asObservable(),
                         registerButtonTapped: registerButton.rx.tap.asObservable(),
                         noButtonTapped: noButton.rx.tap.asObservable(),
                         viewDidDisappear: rx.viewDidDisappear),
            dependency: vmDependency)

        // output
        viewModel.rankingDisplayText
            .bind(to: displayRankLabel.rx.attributedText)
            .disposed(by: disposeBag)
        
        viewModel.totalScoreText
            .bind(to: totalScoreLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.isRegisterButtonEnabled
            .subscribe(onNext: { [weak self] element in
                guard let self = self else { return }
                self.registerButton.isEnabled = element
                self.registerButton.setTitleColor(
                    element ? .black : .lightGray,
                    for: .normal)
            }).disposed(by: disposeBag)
        
        viewModel.dismiss
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        viewModel.isLoading
            .subscribe(onNext: { element in
                if element {
                    HUD.show(.progress)
                }else {
                    HUD.hide()
                }
            }).disposed(by: disposeBag)
        
        viewModel.error
            .subscribe(onNext: { [weak self] element in
                guard let self = self else { return }
                self.present(UIAlertController.errorAlert(element), animated: true)
            }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification, object: nil)
            .subscribe({ (notification) in
                if let element = notification.element {
                    self.keyboardWillShow(notification: element, textField: self.nameTextField, view: self.view)
                }
            })
        .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification, object: nil)
            .subscribe({ (notification) in
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