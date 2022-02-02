//
//  CameraAuthUtil.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2021/02/27.
//

import Foundation
import UIKit
import AVFoundation

class CameraAuthUtil: NSObject, UIImagePickerControllerDelegate {
    
    static func checkCameraAuthorization(vc: UIViewController? = nil) {
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
                    
                    if let vc = vc {
                        //VC上で呼ばれている時だけアラートを表示
                        self.requestPermissionForCamera(vc: vc)
                    }
                }
            }
        case .denied:
            //拒否されているので再設定用のダイアログを表示
            print("拒否されているので再設定用のダイアログを表示")
            
            if let vc = vc {
                //VC上で呼ばれている時だけアラートを表示
                self.requestPermissionForCamera(vc: vc)
            }
        case .restricted:
            //システムによって拒否された、もしくはカメラが存在しない
            print("システムによって拒否された、もしくはカメラが存在しない")
        default:
            print("何らかのエラー")
        }
    }
    
    static func requestPermissionForCamera(vc: UIViewController) {
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
            vc.present(alert, animated: true, completion: nil)
        }
    }
}
