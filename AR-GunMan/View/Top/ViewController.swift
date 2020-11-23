//
//  ViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/04.
//  Copyright © 2020 fukase. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import PanModal

class ViewController: UIViewController {
    
    var replayFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkCameraAuthorization()
        
        if replayFlag {
            presentGameVC(animated: false)
        }
    }

    @IBAction func toGameButtonTapped(_ sender: Any) {
        
        checkCameraAuthorization()
        
        presentGameVC()
        
    }
    
    @IBAction func toSettingButtonTapped(_ sender: Any) {
        
        
        
    }
    
    @IBAction func toTutorialButtonTapped(_ sender: Any) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "TutorialViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
        
        vc.isBlurEffectEnabled = false
        
        let navi = UINavigationController(rootViewController: vc)
        navi.setNavigationBarHidden(true, animated: false)
        
        self.presentPanModal(navi)
    }
    
    
    
    func presentGameVC(animated: Bool = true) {
        let storyboard: UIStoryboard = UIStoryboard(name: "GameViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: animated)
    }
    
}


//カメラ・フォトライブラリ
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            //既に許可済みなのでカメラを表示
            print("既に許可済み")
            
        case .notDetermined:
            //まだ認証をしてないのでアクセスを求める
            print("まだ認証をしてないのでアクセスを求める")
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status {
                    print("許可された")

                }else {
                    print("拒否されたので再設定用のダイアログを表示")
                    self.requestPermissionForCamera()
                }
            }
        case .denied:
            //拒否されているので再設定用のダイアログを表示
            print("拒否されているので再設定用のダイアログを表示")
            self.requestPermissionForCamera()
        case .restricted:
            //システムによって拒否された、もしくはカメラが存在しない
            print("システムによって拒否された、もしくはカメラが存在しない")
        default:
            print("何らかのエラー")
        }
    }
    
    func requestPermissionForCamera() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "カメラへのアクセスを許可", message: "カメラへのアクセスを許可する必要があります。設定を変更して下さい。", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "設定変更", style: .default) { (UIAlertAction) in
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                    print("settingsURLを開けませんでした")
                    return
                }
                print("設定アプリを開きます")
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (UIAlertAction) in
                print("再設定用ダイアログも拒否されたので閉じます")
            }
            alert.addAction(settingsAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
