//
//  RegisterNameViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/05.
//

import UIKit
import Firebase
import RxSwift
import RxCocoa

protocol RegisterNameVCDelegate {
    func showRightButtons()
}

class RegisterNameViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    //前画面から引くつぐゲーム結果のデータ
    var totalScore: Double = 0.000
    var tentativeRank = Int()
    var rankingCount = Int()
    var db: Firestore!
    
    var registerNameVCDelegate: RegisterNameVCDelegate?
    
    @IBOutlet weak var displayRankLabel: UILabel!
    @IBOutlet weak var totalScoreLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var yesRegisterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayRankLabel.attributedText = customAttributedString()
        
        totalScoreLabel.text = "Score: \(String(format: "%.3f", totalScore))"
        
        yesRegisterButton.setTitleColor(UIColor.gray, for: .normal)
        
        //Firestoreへのコネクションの作成
        db = Firestore.firestore()
        
        nameTextField.delegate = self
        
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
    
    //名前が空欄だと登録ボタンを押せなくする　色もグレーにする
    @IBAction func changeRegisterButtonOnOff(_ sender: Any) {
                
        if !(nameTextField.text == "") {
            yesRegisterButton.isEnabled = true
            yesRegisterButton.setTitleColor(.black, for: .normal)
        }else {
            yesRegisterButton.isEnabled = false
            yesRegisterButton.setTitleColor(.lightGray, for: .normal)
        }
    }
    
    //登録するを押した時の処理
    //FireStoreによって世界ランキングへの保存を行う
    @IBAction func yesRegisterButton(_ sender: Any) {
        //入力されたテキストを変数に入れる＆nilの場合はそこで止める
        guard nameTextField.text != nil else {
            return
        }
        //テキストが空欄の場合はそこで止める
        if nameTextField.text == "" {
            return
        }
        
        let threeDigitsScore = Double(round(1000 * totalScore)/1000)
        
        db.collection("worldRanking").addDocument(data: [
            "score": threeDigitsScore,
            "user_name": nameTextField.text ?? "NO NAME"
        ]) { (error) in
            print("error: \(String(describing: error))")
        }
        self.registerNameVCDelegate?.showRightButtons()
        self.presentingViewController?.dismiss(animated: true, completion: nil)

    }
    @IBAction func tappedNoRegisterButton(_ sender: Any) {

        self.registerNameVCDelegate?.showRightButtons()
        self.presentingViewController?.dismiss(animated: true, completion: nil)

    }
    
    
    func customAttributedString() -> NSMutableAttributedString {
        let stringAttributes1: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1),
            .font : UIFont(name: "Copperplate", size: 21.0) ?? UIFont.systemFont(ofSize: 21.0),
        ]
        let string1 = NSAttributedString(string: "You're ranked at ", attributes: stringAttributes1)

        let stringAttributes2: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor(red: 85/255, green: 78/255, blue: 72/255, alpha: 1),
            .font : UIFont(name: "Copperplate", size: 25.0) ?? UIFont.systemFont(ofSize: 25.0),
        ]
        let string2 = NSAttributedString(string: "\(tentativeRank) / \(rankingCount)", attributes: stringAttributes2)
        
        let stringAttributes3: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1),
            .font : UIFont(name: "Copperplate", size: 21.0) ?? UIFont.systemFont(ofSize: 21.0),
        ]
        let string3 = NSAttributedString(string: " in the world!", attributes:stringAttributes3)

        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(string1)
        mutableAttributedString.append(string2)
        mutableAttributedString.append(string3)
        
        return mutableAttributedString
    }
    
}

extension RegisterNameViewController: UITextFieldDelegate {
    
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
