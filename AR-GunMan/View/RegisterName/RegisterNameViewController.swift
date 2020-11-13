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

class RegisterNameViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    //前画面から引くつぐゲーム結果のデータ
    var totalScore:String = "0"
    var db: Firestore!
    
    @IBOutlet weak var totalScoreLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var yesRegisterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalScoreLabel.text = "Score: \(totalScore)"
        
        yesRegisterButton.setTitleColor(UIColor.gray, for: .normal)
        
        //Firestoreへのコネクションの作成
        db = Firestore.firestore()
        
        nameTextField.delegate = self
        
        //背景をぼかし処理
//        let blurEffect = UIBlurEffect(style: .dark)
//        let visualEffectView = UIVisualEffectView(effect: blurEffect)
//        visualEffectView.frame = self.view.frame
//        self.view.insertSubview(visualEffectView, at: 0)
        
        
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
        
        let customBlue = UIColor(red: 229/255, green: 255/255, blue: 255/255, alpha: 1)
        
        if !(nameTextField.text == "") {
            yesRegisterButton.isEnabled = true
            yesRegisterButton.setTitleColor(customBlue, for: .normal)
        }else {
            yesRegisterButton.isEnabled = false
            yesRegisterButton.setTitleColor(UIColor.gray, for: .normal)
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
        
        db.collection("worldRanking").addDocument(data: [
            "score": totalScore,
            "user_name": nameTextField.text ?? ""
        ]) { (error) in
            print("error: \(String(describing: error))")
        }
//
//        let storyboard: UIStoryboard = UIStoryboard(name: "WorldRankingViewController", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "WorldRankingViewController") as! WorldRankingViewController
//        self.present(vc, animated: true)
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func tappedNoRegisterButton(_ sender: Any) {
        
//        let storyboard: UIStoryboard = UIStoryboard(name: "WorldRankingViewController", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "WorldRankingViewController") as! WorldRankingViewController
//        self.present(vc, animated: true)
        self.dismiss(animated: true, completion: nil)
        
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
