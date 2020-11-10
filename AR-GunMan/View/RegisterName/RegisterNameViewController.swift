//
//  RegisterNameViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/05.
//

import UIKit
import Firebase

class RegisterNameViewController: UIViewController {
    
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
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = self.view.frame
        self.view.insertSubview(visualEffectView, at: 0)
        
    }
    
    //名前が空欄だと登録ボタンを押せなくする　色もグレーにする
    @IBAction func changeRegisterButtonOnOff(_ sender: Any) {
        if !(nameTextField.text == "") {
            yesRegisterButton.isEnabled = true
            yesRegisterButton.setTitleColor(UIColor.systemPink, for: .normal)
        }else {
            yesRegisterButton.isEnabled = false
            yesRegisterButton.setTitleColor(UIColor.gray, for: .normal)
        }
    }
    
    //登録するを押した時の処理
    //FireStoreによって世界ランキングへの保存を行う
    @IBAction func yesRegisterButton(_ sender: Any) {
        //入力されたテキストを変数に入れる＆nilの場合はそこで止める
        guard let rankingName = nameTextField.text else {
            return
        }
        //テキストが空欄の場合はそこで止める
        if nameTextField.text == "" {
            return
        }
        
        let nameAndScoreArr = [rankingName, totalScore]
        let nameAndScoreDictionary:[String: String] = [rankingName: totalScore]
        
        db.collection("worldRanking").addDocument(data: nameAndScoreDictionary)
        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func tappedNoRegisterButton(_ sender: Any) {
        
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
    
}
