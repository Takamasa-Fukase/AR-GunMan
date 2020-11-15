//
//  GameViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/08/15.
//  Copyright © 2020 fukase. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import CoreMotion
import AVFoundation
import AudioToolbox
import FSPagerView

class GameViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    let motionManager = CMMotionManager()
    
    var audioPlayer1 = AVAudioPlayer()
    var audioPlayer2 = AVAudioPlayer()
    var audioPlayer3 = AVAudioPlayer()
    var audioPlayer4 = AVAudioPlayer()
    var audioPlayer5 = AVAudioPlayer()
    
    var targetCount = 200
    
    var toggleActionInterval = 0.2
    var lastCameraPos = SCNVector3()
    var isPlayerRunning = false
    var lastPlayerStatus = false
    
    var currentWeaponIndex = 0
    
    var timer:Timer!
    var timeCount:Double = 10.00
    
    private var presenter: GamePresenter?
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var pistolBulletsCountImageView: UIImageView!
    @IBOutlet weak var targetCountLabel: UILabel!
    
    @IBOutlet weak var switchWeaponButton: UIButton!
    
    var bulletNode: SCNNode?
    var targetNode: SCNNode?
    var kingTaimeiSan: SCNNode?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScnView()
        getAccelerometer()
        getGyro()
        
        let sphere: SCNGeometry = SCNSphere(radius: 0.05)
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        
        let scene = SCNScene(named: "art.scnassets/target.scn")
        targetNode = (scene?.rootNode.childNode(withName: "target", recursively: false))!
        targetNode?.scale = SCNVector3(0.25, 0.25, 0.25)
        
        //当たり判定用のphysicBodyを追加
        targetNode?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        targetNode?.physicsBody?.isAffectedByGravity = false
        
        self.presenter = GamePresenter(listener: self)
        presenter?.viewDidLoad()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(timerUpdate(timer:)), userInfo: nil, repeats: true)
        
        targetCountLabel.font = targetCountLabel.font.monospacedDigitFont

        
    }
    
    //タイマーで指定間隔ごとに呼ばれる関数
    @objc func timerUpdate(timer: Timer) {
        let lowwerTime = 0.00
        timeCount = max(timeCount - 0.01, lowwerTime)
        let strTimeCount = String(format: "%.2f", timeCount)
        let twoDigitTimeCount = timeCount > 10 ? "\(strTimeCount)" : "0\(strTimeCount)"
        targetCountLabel.text = twoDigitTimeCount
        
        //タイマーが0になったらタイマーを破棄して結果画面へ遷移
        if timeCount <= 0 {
            timer.invalidate()
            let storyboard: UIStoryboard = UIStoryboard(name: "WorldRankingViewController", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "WorldRankingViewController") as! WorldRankingViewController
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func switchWeaponButtonTapped(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "SwitchWeaponViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SwitchWeaponViewController") as! SwitchWeaponViewController
        vc.modalPresentationStyle = .overCurrentContext
        
        vc.switchWeaponDelegate = self
        
        self.present(vc, animated: true)
    }
    
    
    func setupScnView() {
        //シーンの作成
        sceneView.scene = SCNScene()
        //光源の有効化
        sceneView.autoenablesDefaultLighting = true;
        //ARSCNViewデリゲートの指定
        sceneView.delegate = self
        //衝突検知のためのDelegate設定
        sceneView.scene.physicsWorld.contactDelegate = self
    }
    
    //ビュー表示時に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //コンフィギュレーションの生成
        let configuration = ARWorldTrackingConfiguration()
        //平面検出の有効化
        configuration.planeDetection = .horizontal
        //セッションの開始
        sceneView.session.run(configuration)
    }
    
    //ビュー非表示時に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //セッションの一時停止
        sceneView.session.pause()
    }
    
    //常に更新され続けるdelegateメソッド
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //現在表示中の武器をラップしている空のオブジェクトを常にカメラと同じPositionに移動させ続ける（それにより武器が常にFPS位置に保たれる）
        if let pistol = sceneView.scene.rootNode.childNode(withName: "parent", recursively: false) {
            pistol.position = sceneView.pointOfView?.position ?? SCNVector3()
        }
        if let bazooka = sceneView.scene.rootNode.childNode(withName: "bazookaParent", recursively: false) {
            bazooka.position = sceneView.pointOfView?.position ?? SCNVector3()
        }
        
        if toggleActionInterval <= 0 {
            guard let currentPos = sceneView.pointOfView?.position else {return}
            let diff = SCNVector3Make(lastCameraPos.x - currentPos.x, lastCameraPos.y - currentPos.y, lastCameraPos.z - currentPos.z)
            let distance = sqrt((diff.x * diff.x) + (diff.y * diff.y) + (diff.z * diff.z))
//            print("0.2秒前からの移動距離: \(String(format: "%.1f", distance))m")
            
            isPlayerRunning = (distance >= 0.15)
            
            if isPlayerRunning != lastPlayerStatus {
                
                switch currentWeaponIndex {
                case 0:
                    sceneView.scene.rootNode.childNode(withName: "parent", recursively: false)?.childNode(withName: "M1911_a", recursively: false)?.removeAllActions()
                    sceneView.scene.rootNode.childNode(withName: "parent", recursively: false)?.childNode(withName: "M1911_a", recursively: false)?.position = SCNVector3(0.17, -0.197, -0.584)
                    sceneView.scene.rootNode.childNode(withName: "parent", recursively: false)?.childNode(withName: "M1911_a", recursively: false)?.eulerAngles = SCNVector3(-1.4382625, 1.3017014, -2.9517007)
                case 5:
                    sceneView.scene.rootNode.childNode(withName: "bazookaParent", recursively: false)?.childNode(withName: "bazooka", recursively: false)?.removeAllActions()
                    sceneView.scene.rootNode.childNode(withName: "bazookaParent", recursively: false)?.childNode(withName: "bazooka", recursively: false)?.position = SCNVector3(0, 0, 0)
                    sceneView.scene.rootNode.childNode(withName: "bazookaParent", recursively: false)?.childNode(withName: "bazooka", recursively: false)?.eulerAngles = SCNVector3(0, 0, 0)
                default: break
                }

                isPlayerRunning ? gunnerShakeAnimationRunning(currentWeaponIndex) : gunnerShakeAnimationNormal(currentWeaponIndex)
            }
            self.toggleActionInterval = 0.2
            lastCameraPos = sceneView.pointOfView?.position ?? SCNVector3()
            lastPlayerStatus = isPlayerRunning
        }
        toggleActionInterval -= 0.02
    }
    
    func gunnerShakeAnimationNormal(_ weaponIndex: Int) {
        //銃の先端が上に跳ね上がる回転のアニメーション
        let rotateAction = SCNAction.rotateBy(x: -0.1779697224, y: 0.0159312604, z: -0.1784194, duration: 1.2)
        //↑の逆（下に戻る回転）
        let reverse = rotateAction.reversed()
        //上下のアニメーションを直列に実行するアニメーション
        let rotate = SCNAction.sequence([rotateAction, reverse])
        
        //銃が垂直に持ち上がるアニメーション
        let moveUp = SCNAction.moveBy(x: 0, y: 0.01, z: 0, duration: 0.8)
        //↑の逆（垂直に下に下がる）
        let moveDown = moveUp.reversed()
        //上下のアニメーションを直列に実行するアニメーション
        let move = SCNAction.sequence([moveUp, moveDown])
        
        //回転と上下移動のアニメーションを並列に同時実行するアニメーション(それぞれのdurationをずらすことによって不規則な動き感を出している)
        let conbineAction = SCNAction.group([rotate, move])
        
        //↑を永遠繰り返すアニメーション
        let repeatAction = SCNAction.repeatForever(conbineAction)
        
        //実行
        switch weaponIndex {
        case 0:
            sceneView.scene.rootNode.childNode(withName: "parent", recursively: false)?.childNode(withName: "M1911_a", recursively: false)?.runAction(repeatAction)
        case 5:
            sceneView.scene.rootNode.childNode(withName: "bazookaParent", recursively: false)?.childNode(withName: "bazooka", recursively: false)?.runAction(repeatAction)
        default: break
        }
    }
    
    func gunnerShakeAnimationRunning(_ weaponIndex: Int) {
        //銃が右に移動するアニメーション
        let moveRight = SCNAction.moveBy(x: 0.03, y: 0, z: 0, duration: 0.3)
        //↑の逆（左に移動）
        let moveLeft = moveRight.reversed()
        
        //銃が垂直に持ち上がるアニメーション
        let moveUp = SCNAction.moveBy(x: 0, y: 0.02, z: 0, duration: 0.15)
        //↑の逆（垂直に下に下がる）
        let moveDown = moveUp.reversed()
        //上下交互
        let upAndDown = SCNAction.sequence([moveUp, moveDown])
        
        let rightAndUpDown = SCNAction.group([moveRight, upAndDown])
        let LeftAndUpDown = SCNAction.group([moveLeft, upAndDown])
        
        //回転と上下移動のアニメーションを並列に同時実行するアニメーション(それぞれのdurationをずらすことによって不規則な動き感を出している)
        let conbineAction = SCNAction.sequence([rightAndUpDown, LeftAndUpDown])
        
        //↑を永遠繰り返すアニメーション
        let repeatAction = SCNAction.repeatForever(conbineAction)
        
        //実行
        switch weaponIndex {
        case 0:
            sceneView.scene.rootNode.childNode(withName: "parent", recursively: false)?.childNode(withName: "M1911_a", recursively: false)?.runAction(repeatAction)
        case 5:
            sceneView.scene.rootNode.childNode(withName: "bazookaParent", recursively: false)?.childNode(withName: "bazooka", recursively: false)?.runAction(repeatAction)
        default: break
        }
    }
    
    func shootingAnimation() {
        //発砲時に銃の先端が上に跳ね上がる回転のアニメーション
        let rotateAction = SCNAction.rotateBy(x: -0.9711356901, y: -0.08854044763, z: -1.013580166, duration: 0.1)
        //↑の逆（下に戻る回転）
        let reverse = rotateAction.reversed()
        //上下のアニメーションを直列に実行するアニメーション
        let shoot = SCNAction.sequence([rotateAction, reverse])
        
        //実行
        sceneView.scene.rootNode.childNode(withName: "parent", recursively: false)?.childNode(withName: "M1911_a", recursively: false)?.runAction(shoot)
    }
    
    func addExplosion() {
        let scene = SCNScene(named: "art.scnassets/Explosion1.scn")
        //注意:scnのファイル名ではなく、Identity欄のnameを指定する
        let node = (scene?.rootNode.childNode(withName: "Explosion1", recursively: false))!
        
        let pos = sceneView.pointOfView?.position ?? SCNVector3()
        node.position = SCNVector3(pos.x, pos.y - 10, pos.z - 10)
//        node.scale = SCNVector3(1, 1, 1)
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    //衝突検知時に呼ばれる
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        if (nodeA.name == "bullet" && nodeB.name == "target") || (nodeB.name == "bullet" && nodeA.name == "target") {
            print("当たった")
            audioPlayer5.play()
            nodeA.removeFromParentNode()
            nodeB.removeFromParentNode()
            targetCount -= 1
            DispatchQueue.main.async {
//                self.targetCountLabel.text = "残り\(self.targetCount)個！"
            }
        }
    }
    
    //加速度設定
    func getAccelerometer() {
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue()) {
            (data, error) in
            DispatchQueue.main.async {
                guard let acceleration = data?.acceleration else { return }
                self.presenter?.accele = acceleration
                self.presenter?.didUpdateAccelerationData(data: acceleration)
            }
        }
    }
    //ジャイロ設定
    func getGyro() {
        motionManager.gyroUpdateInterval = 0.2
        motionManager.startGyroUpdates(to: OperationQueue()) {
            (data, error) in
            DispatchQueue.main.async {
                guard let rotationRate = data?.rotationRate else { return }
                self.presenter?.gyro = rotationRate
                self.presenter?.didUpdateGyroData(data: rotationRate)
            }
        }
    }
}

//SwitchWeaponVCでのセルタップをトリガーに発火させる武器切り替えメソッド
extension GameViewController: SwitchWeaponDelegate {
    
    func selectedAt(index: Int) {
        
        print("current: \(currentWeaponIndex), selectedAt: \(index)")
        
        //同じ武器を選択した場合は何も処理しないで終了
        guard index != currentWeaponIndex else {
            print("同じ武器を選択した場合は何も処理しないで終了")
            return}
        
        switch index {
        case 0:
            addPistol()
        case 5:
            addBazooka()
        default:
            print("まだ開発中の武器が選択されたので何も処理せずに終了")
            return
        }
        
        currentWeaponIndex = index
        
    }
    
}

extension GameViewController: GameInterface {
    func addPistol() {
        //バズーカを削除
        if let detonator = self.sceneView.scene.rootNode.childNode(withName: "bazookaParent", recursively: false) {
            print("bazookaを削除しました")
            detonator.removeFromParentNode()
        }
        let scene = SCNScene(named: "art.scnassets/Weapon/Pistol/M1911_a.scn")
        //注意:scnのファイル名ではなく、Identity欄のnameを指定する
        let parentNode = (scene?.rootNode.childNode(withName: "parent", recursively: false))!
        
        let billBoardConstraint = SCNBillboardConstraint()
        parentNode.constraints = [billBoardConstraint]
        
        parentNode.position = sceneView.pointOfView?.position ?? SCNVector3()
        self.sceneView.scene.rootNode.addChildNode(parentNode)
        
        //チャキッ　の再生
        self.audioPlayer1.play()
        
        gunnerShakeAnimationNormal(0)
    }
    
    func addBazooka() {
        //ピストルを削除
        if let detonator = self.sceneView.scene.rootNode.childNode(withName: "parent", recursively: false) {
            print("pistolを削除しました")
            detonator.removeFromParentNode()
        }
        let scene = SCNScene(named: "art.scnassets/Weapon/RocketLauncher/bazooka2.scn")
        //注意:scnのファイル名ではなく、Identity欄のnameを指定する
        let bazooka = (scene?.rootNode.childNode(withName: "bazookaParent", recursively: false))!
        
        let billBoardConstraint = SCNBillboardConstraint()
        bazooka.constraints = [billBoardConstraint]
        
        bazooka.position = sceneView.pointOfView?.position ?? SCNVector3()
        self.sceneView.scene.rootNode.addChildNode(bazooka)
        
        //チャキッ　の再生
        self.audioPlayer1.play()
        
        gunnerShakeAnimationNormal(5)
    }
    
    //弾ノードを設置
    func addBullet() {
        guard let cameraPos = sceneView.pointOfView?.position else {return}
        //        guard bulletNode == nil else {return}
        let position = SCNVector3(x: cameraPos.x, y: cameraPos.y, z: cameraPos.z)
        let sphere: SCNGeometry = SCNSphere(radius: 0.05)
        let customYellow = UIColor(red: 253/255, green: 202/255, blue: 119/255, alpha: 1)
        
        sphere.firstMaterial?.diffuse.contents = customYellow
        bulletNode = SCNNode(geometry: sphere)
        guard let bulletNode = bulletNode else {return}
        bulletNode.name = "bullet"
        bulletNode.scale = SCNVector3(x: 1, y: 1, z: 1)
        bulletNode.position = position
        
        //当たり判定用のphysicBodyを追加
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        bulletNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        bulletNode.physicsBody?.contactTestBitMask = 1
        bulletNode.physicsBody?.isAffectedByGravity = false
        
        sceneView.scene.rootNode.addChildNode(bulletNode)
        
        print("弾を設置")
    }
    
    //弾ノードを発射
    func shootBullet() {
        guard let camera = sceneView.pointOfView else {return}
        let targetPosCamera = SCNVector3(x: camera.position.x, y: camera.position.y, z: camera.position.z - 10)
        //カメラ座標をワールド座標に変換
        let target = camera.convertPosition(targetPosCamera, to: nil)
        let action = SCNAction.move(to: target, duration: TimeInterval(1))
        bulletNode?.runAction(action, completionHandler: {
            self.bulletNode?.removeFromParentNode()
        })
        
        shootingAnimation()
        
        print("弾を発射")
    }
    
    //的ノードを設置
    func addTarget() {
//        let sphere: SCNGeometry = SCNSphere(radius: 0.05)
//        sphere.firstMaterial?.diffuse.contents = UIColor.red
//
//        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        
        //ランダムな座標に10回設置
        DispatchQueue.main.async {
            for _ in 0..<self.targetCount {
//                let randomX = Float.random(in: -3...3)
//                let randomY = Float.random(in: -1...1)
//                let randomZ = Float.random(in: -3...(-0.5))
                let randomX = Float.random(in: -3...3)
                let randomY = Float.random(in: -1.5...2)
                let randomZfirst = Float.random(in: -3...(-0.5))
                let randomZsecond = Float.random(in: 0.5...3)
                let randomZthird = Float.random(in: -3...3)
                var randomZ: Float?
                
                if randomX < -0.5 || randomX > 0.5 || randomY < -0.5 || randomY > 0.5 {
                    randomZ = randomZthird
                }else {
                    randomZ = [randomZfirst, randomZsecond].randomElement()
                }
                let randomPosition = SCNVector3(x: randomX, y: randomY, z: randomZ ?? 0)
                
                let cloneTargetNode = self.targetNode?.clone()
                
                cloneTargetNode?.position = randomPosition
                self.sceneView.scene.rootNode.addChildNode(cloneTargetNode ?? SCNNode())
                print("的を設置")
            }
        }
    }
    
    func setSounds(for soundType: SoundType?) {
        setAudioPlayer(forIndex: 1, resourceFileName: "pistol-slide")
        setAudioPlayer(forIndex: 2, resourceFileName: "pistol-fire")
        setAudioPlayer(forIndex: 3, resourceFileName: "pistol-out-bullets")
        setAudioPlayer(forIndex: 4, resourceFileName: "pistol-reload")
        setAudioPlayer(forIndex: 5, resourceFileName: "headShot")
    }
    
    func playSound(of index: Int) {
        switch index {
        case 1:
            audioPlayer1.currentTime = 0
            audioPlayer1.play()
        case 2:
            audioPlayer2.currentTime = 0
            audioPlayer2.play()
        case 3:
            audioPlayer3.currentTime = 0
            audioPlayer3.play()
        case 4:
            audioPlayer4.currentTime = 0
            audioPlayer4.play()
        case 5:
            audioPlayer5.currentTime = 0
            audioPlayer5.play()
        default: break
        }
    }
    
    func vibration() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func setBulletsImageView(with image: UIImage?) {
        pistolBulletsCountImageView.image = image
    }
}

extension GameViewController: AVAudioPlayerDelegate {

    private func setAudioPlayer(forIndex index: Int, resourceFileName: String) {
        guard let path = Bundle.main.path(forResource: resourceFileName, ofType: "mp3") else {
            print("音源\(index)が見つかりません")
            return
        }
        do {
            switch index {
            case 1:
                audioPlayer1 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer1.prepareToPlay()
            case 2:
                audioPlayer2 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer2.prepareToPlay()
            case 3:
                audioPlayer3 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer3.prepareToPlay()
            case 4:
                audioPlayer4 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer4.prepareToPlay()
            case 5:
                audioPlayer5 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer5.prepareToPlay()
            default:
                break
            }
        } catch {
            print("音声セットエラー")
        }
    }
}





//タイムカウント（0.01秒刻みで動く）を等幅フォントにして左右のブレをなくす設定
extension UIFont {
    var monospacedDigitFont: UIFont {
        let oldFontDescriptor = fontDescriptor
        let newFontDescriptor = oldFontDescriptor.monospacedDigitFontDescriptor
        return UIFont(descriptor: newFontDescriptor, size: 0)
    }
}

private extension UIFontDescriptor {
    var monospacedDigitFontDescriptor: UIFontDescriptor {
        let fontDescriptorFeatureSettings = [[UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType, UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector]]
        let fontDescriptorAttributes = [UIFontDescriptor.AttributeName.featureSettings: fontDescriptorFeatureSettings]
        let fontDescriptor = self.addingAttributes(fontDescriptorAttributes)
        return fontDescriptor
    }
}
