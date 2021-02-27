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
import PanModal

class GameViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    let motionManager = CMMotionManager()
    
    
    
    var targetCount = 50
    
    var pistolPoint = 0.0
    var bazookaPoint = 0.0
    
    var toggleActionInterval = 0.2
    var lastCameraPos = SCNVector3()
    var isPlayerRunning = false
    var lastPlayerStatus = false
    
    var currentWeaponIndex = 0
    
    var timer:Timer!
    var timeCount:Double = 30.00
    
    var explosionCount = 0
    
    var exploPar: SCNParticleSystem?
    
    var bulletNode: SCNNode?
    var bazookaHitExplosion: SCNNode?
    var jetFire: SCNNode?
    var targetNode: SCNNode?
    
    private var presenter: GamePresenter?
    var viewModel = GameViewModel()
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var pistolBulletsCountImageView: UIImageView!
    @IBOutlet weak var sightImageView: UIImageView!
    @IBOutlet weak var targetCountLabel: UILabel!
    
    @IBOutlet weak var switchWeaponButton: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScnView()
        getAccelerometer()
        getGyro()
        
        let scene = SCNScene(named: "art.scnassets/target.scn")
        targetNode = (scene?.rootNode.childNode(withName: "target", recursively: false))!
        targetNode?.scale = SCNVector3(0.3, 0.3, 0.3)
        
        let targetNodeGeometry = (targetNode?.childNode(withName: "sphere", recursively: false)?.geometry)!
        
        //MARK: - 当たり判定の肝2つ
        //①形状はラップしてる空のNodeではなく何か1つgeometryを持っているものにするを指定する
        //②当たり判定のscaleはoptions: [SCNPhysicsShape.Option.scale: SCNVector3]で明示的に設定する（大体①のgeometryの元となっているNodeのscaleを代入すれば等しい当たり判定になる）
        let shape = SCNPhysicsShape(geometry: targetNodeGeometry, options: [SCNPhysicsShape.Option.scale: targetNode?.scale])
        
        //当たり判定用のphysicBodyを追加
        targetNode?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        targetNode?.physicsBody?.isAffectedByGravity = false
        
        
        //ロケラン名中時の爆発
        
        //art.scnassets配下のファイル名までのパスを記載
        let explosionScene = SCNScene(named: "art.scnassets/ParticleSystems/ExplosionSamples/Explosion1.scn")
        
        //注意: withNameにはscnのファイル名ではなく、Identity欄のnameを指定する
        if let explosion = (explosionScene?.rootNode.childNode(withName: "Explosion1", recursively: false)) {
            
            //座標を指定したい場合はここで設定（↓ではカメラ位置よりも50cm前方を指定）
            let cameraPos = self.sceneView.pointOfView?.position ?? SCNVector3()
            explosion.position = SCNVector3(x: cameraPos.x, y: cameraPos.y, z: cameraPos.z - 0.5)
            
            //画面に反映
            self.sceneView.scene.rootNode.addChildNode(explosion)

        }
        
        //ParticleSystemへのアクセス方法
        sceneView.scene.rootNode.childNode(withName: "Explosion1", recursively: false)?.particleSystems?.first
        
        
        
        if let particleSystem = sceneView.scene.rootNode.childNode(withName: "bazookaHitExplosion\(explosionCount)", recursively: false)?.particleSystems?.first  {
            
            particleSystem.birthRate = 300
            particleSystem.loops = false
            
        }
        
        exploPar = bazookaHitExplosion?.particleSystems?.first!
        
        
        self.presenter = GamePresenter(listener: self)
        presenter?.viewDidLoad()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        
//            self.startWhistle.play()
//
//            self.presenter?.isShootEnabled = true
//
//            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.timerUpdate(timer:)), userInfo: nil, repeats: true)
//        }
        
        targetCountLabel.font = targetCountLabel.font.monospacedDigitFont

        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.value(forKey: "tutorialAlreadySeen") == nil {
            
            let storyboard: UIStoryboard = UIStoryboard(name: "TutorialViewController", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
            vc.delegate = self
            self.present(vc, animated: true)
            
        }else {
            print("tutorialAlreadySeen=true")
            
            AudioModel.playSound(of: .pistolSet)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                AudioModel.playSound(of: .startWhistle)
                
                self.presenter?.isShootEnabled = true
                
                self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.timerUpdate(timer:)), userInfo: nil, repeats: true)
            }
        }
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
            presenter?.isShootEnabled = false

            AudioModel.playSound(of: .endWhistle)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                
                self.viewModel.rankingWillAppear.onNext(Void())
                
                AudioModel.playSound(of: .rankingAppear)
                
                let storyboard: UIStoryboard = UIStoryboard(name: "WorldRankingViewController", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "WorldRankingViewController") as! WorldRankingViewController
                
                let sumPoint: Double = min(self.pistolPoint + self.bazookaPoint, 100.0)
                
                let totalScore = sumPoint * (Double.random(in: 0.9...1))
                
                print("pistolP: \(self.pistolPoint), bazookaP: \(self.bazookaPoint), sumP: \(sumPoint) totalScore: \(totalScore)")
                
                vc.totalScore = totalScore
                self.present(vc, animated: true)
            })
            
        }
    }
    
    @IBAction func switchWeaponButtonTapped(_ sender: Any) {
        
        sightImageView.image = nil
        pistolBulletsCountImageView.image = nil
        presenter?.isShootEnabled = false
        
        let storyboard: UIStoryboard = UIStoryboard(name: "SwitchWeaponViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SwitchWeaponViewController") as! SwitchWeaponViewController
        
        vc.switchWeaponDelegate = self
        vc.viewModel = self.viewModel
        
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
        if let rifle = sceneView.scene.rootNode.childNode(withName: "AKM_parent", recursively: false) {
            rifle.position = sceneView.pointOfView?.position ?? SCNVector3()
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
                case 1:
//                    sceneView.scene.rootNode.childNode(withName: "bazookaParent", recursively: false)?.childNode(withName: "bazooka", recursively: false)?.removeAllActions()
//                    sceneView.scene.rootNode.childNode(withName: "bazookaParent", recursively: false)?.childNode(withName: "bazooka", recursively: false)?.position = SCNVector3(0, 0, 0)
//                    sceneView.scene.rootNode.childNode(withName: "bazookaParent", recursively: false)?.childNode(withName: "bazooka", recursively: false)?.eulerAngles = SCNVector3(0, 0, 0)
                
                    sceneView.scene.rootNode.childNode(withName: "AKM_parent", recursively: false)?.childNode(withName: "AKM", recursively: false)?.removeAllActions()
                    sceneView.scene.rootNode.childNode(withName: "AKM_parent", recursively: false)?.childNode(withName: "AKM", recursively: false)?.position = SCNVector3(0, 0, 0)
                    sceneView.scene.rootNode.childNode(withName: "AKM_parent", recursively: false)?.childNode(withName: "AKM", recursively: false)?.eulerAngles = SCNVector3(0, 0, 0)
                
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
        let rotate = SCNAction.rotateBy(x: -0.1779697224, y: 0.0159312604, z: -0.1784194, duration: 1.2)
        //↑の逆（下に戻る回転）
        let rotateReverse = rotate.reversed()
        //上下のアニメーションを直列に実行するアニメーション
        let rotateAction = SCNAction.sequence([rotate, rotateReverse])
        
        
        //銃が垂直に持ち上がるアニメーション
        let moveUp = SCNAction.moveBy(x: 0, y: 0.01, z: 0, duration: 0.8)
        //↑の逆（垂直に下に下がる）
        let moveDown = moveUp.reversed()
        //上下のアニメーションを直列に実行するアニメーション
        let moveAction = SCNAction.sequence([moveUp, moveDown])
        
        
        //回転と上下移動のアニメーションを並列に同時実行するアニメーション(それぞれのdurationをずらすことによって不規則な動き感を出している)
        let conbineAction = SCNAction.group([rotateAction, moveAction])
        
        //↑を永遠繰り返すアニメーション
        let gunnerShakeAction = SCNAction.repeatForever(conbineAction)
        
        //実行
        sceneView.scene.rootNode.childNode(withName: "parentNode", recursively: false)?.childNode(withName: "M1911", recursively: false)?.runAction(gunnerShakeAction)

        
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
//        case 5:
//            sceneView.scene.rootNode.childNode(withName: "bazookaParent", recursively: false)?.childNode(withName: "bazooka", recursively: false)?.runAction(repeatAction)
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

    //衝突検知時に呼ばれる
    //MEMO: - このメソッド内でUIの更新を行いたい場合はmainThreadで行う
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        if (nodeA.name == "bullet" && nodeB.name == "target") || (nodeB.name == "bullet" && nodeA.name == "target") {
            print("当たった")
            AudioModel.playSound(of: .headShot)
            nodeA.removeFromParentNode()
            nodeB.removeFromParentNode()
            
            if currentWeaponIndex == 1 {
                AudioModel.playSound(of: .bazookaHit)
                
                if let first = sceneView.scene.rootNode.childNode(withName: "bazookaHitExplosion\(explosionCount)", recursively: false)?.particleSystems?.first  {
                    
                    first.birthRate = 300
                    first.loops = false
                    
                }
            }
            
            switch currentWeaponIndex {
            case 0:
                pistolPoint += 5
            case 1:
                bazookaPoint += 12
            default:
                break
            }
            
            targetCount -= 1
        }
    }
    
    //加速度設定
    func getAccelerometer() {
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) {
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
        motionManager.startGyroUpdates(to: OperationQueue.current!) {
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
        
        switch index {
        case 0:
            if index != currentWeaponIndex {
                addPistol()
            }
            setBulletsImageView(with: UIImage(named: "bullets\(presenter?.pistolBulletsCount ?? 0)"))
            pistolBulletsCountImageView.contentMode = .scaleAspectFit
            sightImageView.image = UIImage(named: "pistolSight")
            sightImageView.tintColor = .systemRed
            
        case 1:
            if index != currentWeaponIndex {
                addRifle()
            }
            setBulletsImageView(with: UIImage(named: "bullets\(presenter?.pistolBulletsCount ?? 0)"))
            pistolBulletsCountImageView.contentMode = .scaleAspectFit
            sightImageView.image = UIImage(named: "pistolSight")
            sightImageView.tintColor = .systemRed
            
        case 2:
            if index != currentWeaponIndex {
                addBazooka()
            }
            setBulletsImageView(with: UIImage(named: "bazookaRocket\(presenter?.bazookaRocketCount ?? 0)"))
            pistolBulletsCountImageView.contentMode = .scaleAspectFill
            sightImageView.image = UIImage(named: "bazookaSight")
            sightImageView.tintColor = .systemGreen
            
        default:
            print("まだ開発中の武器が選択されたので何も処理せずに終了")
            return
        }
        
        currentWeaponIndex = index
        presenter?.currentWeaponIndex = index
        presenter?.isShootEnabled = true
        
    }
    
}

extension GameViewController: TutorialVCDelegate {
    func startGame() {
        AudioModel.playSound(of: .pistolSet)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            
            AudioModel.playSound(of: .startWhistle)
            
            self.presenter?.isShootEnabled = true
            
            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.timerUpdate(timer:)), userInfo: nil, repeats: true)
        }
    }
}

extension GameViewController: GameInterface {
    func addPistol(shouldPlayPistolSet: Bool = true) {
        //バズーカを削除
        if let bazooka = self.sceneView.scene.rootNode.childNode(withName: "bazookaParent", recursively: false) {
            print("bazookaを削除しました")
            bazooka.removeFromParentNode()
        } else if let rifle = self.sceneView.scene.rootNode.childNode(withName: "AKM_parent", recursively: false) {
            print("rifleを削除しました")
            rifle.removeFromParentNode()
        }
        let scene = SCNScene(named: "art.scnassets/Weapon/Pistol/M1911_a.scn")
        //注意:scnのファイル名ではなく、Identity欄のnameを指定する
        let parentNode = (scene?.rootNode.childNode(withName: "parent", recursively: false))!
        
        let billBoardConstraint = SCNBillboardConstraint()
        parentNode.constraints = [billBoardConstraint]
        
        parentNode.position = sceneView.pointOfView?.position ?? SCNVector3()
        self.sceneView.scene.rootNode.addChildNode(parentNode)
        
        if shouldPlayPistolSet {
            //チャキッ　の再生
            AudioModel.playSound(of: .pistolSet)
        }
        
        gunnerShakeAnimationNormal(0)
    }
    
    func addBazooka() {
        //ピストルを削除
        if let pistol = self.sceneView.scene.rootNode.childNode(withName: "parent", recursively: false) {
            print("pistolを削除しました")
            pistol.removeFromParentNode()
        } else if let rifle = self.sceneView.scene.rootNode.childNode(withName: "AKM_parent", recursively: false) {
            print("rifleを削除しました")
            rifle.removeFromParentNode()
        }
        let scene = SCNScene(named: "art.scnassets/Weapon/RocketLauncher/bazooka2.scn")
        //注意:scnのファイル名ではなく、Identity欄のnameを指定する
        let bazooka = (scene?.rootNode.childNode(withName: "bazookaParent", recursively: false))!
        
        let billBoardConstraint = SCNBillboardConstraint()
        bazooka.constraints = [billBoardConstraint]
        
        bazooka.position = sceneView.pointOfView?.position ?? SCNVector3()
        self.sceneView.scene.rootNode.addChildNode(bazooka)

        //チャキッ　の再生
        AudioModel.playSound(of: .bazookaSet)
        
        gunnerShakeAnimationNormal(5)
    }
    
    func addRifle() {
        //ピストルを削除
        if let detonator = self.sceneView.scene.rootNode.childNode(withName: "parent", recursively: false) {
            print("pistolを削除しました")
            detonator.removeFromParentNode()
        } else if let detonator = self.sceneView.scene.rootNode.childNode(withName: "bazookaParent", recursively: false) {
            print("bazookaを削除しました")
            detonator.removeFromParentNode()
        }
        let scene = SCNScene(named: "art.scnassets/Weapon/Rifle/AKM.scn")
        //注意:scnのファイル名ではなく、Identity欄のnameを指定する
        let rifle = (scene?.rootNode.childNode(withName: "AKM_parent", recursively: false))!
        
        let billBoardConstraint = SCNBillboardConstraint()
        rifle.constraints = [billBoardConstraint]
        
        rifle.position = sceneView.pointOfView?.position ?? SCNVector3()
        self.sceneView.scene.rootNode.addChildNode(rifle)

        //チャキッ　の再生
        AudioModel.playSound(of: .pistolSet)
        
//        gunnerShakeAnimationNormal(5)
    }
    
    //弾ノードを設置
    func addBullet() {
        guard let cameraPos = sceneView.pointOfView?.position else {return}

        let sphere: SCNGeometry = SCNSphere(radius: 0.05)
        let customYellow = UIColor(red: 253/255, green: 202/255, blue: 119/255, alpha: 1)
        
        sphere.firstMaterial?.diffuse.contents = customYellow
        bulletNode = SCNNode(geometry: sphere)
        guard let bulletNode = bulletNode else {return}
        bulletNode.name = "bullet"
        bulletNode.scale = SCNVector3(x: 1, y: 1, z: 1)
        bulletNode.position = cameraPos
        
        //当たり判定用のphysicBodyを追加
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        bulletNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        bulletNode.physicsBody?.contactTestBitMask = 1
        bulletNode.physicsBody?.isAffectedByGravity = false

        if currentWeaponIndex == 1 {
            explosionCount += 1

            var parti: SCNParticleSystem? = SCNParticleSystem()
            parti?.loops = true
            
            parti = exploPar
            
            parti?.loops = true
            
            if let par = parti {

                par.birthRate = 0
                let node = SCNNode()
                node.addParticleSystem(par)
                node.name = "bazookaHitExplosion\(explosionCount)"
                node.position = cameraPos
                sceneView.scene.rootNode.addChildNode(node)
            }
            
        }
        
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
        
        if currentWeaponIndex == 1 {

            sceneView.scene.rootNode.childNode(withName: "bazookaHitExplosion\(explosionCount)", recursively: false)?.runAction(action)
            
        }
        
        shootingAnimation()
        
        print("弾を発射")
    }
    
    //的ノードを設置
    func addTarget() {
        
        //ランダムな座標に10回設置
        DispatchQueue.main.async {
            for _ in 0..<self.targetCount {

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
                
                //常にカメラを向く制約
                let billBoardConstraint = SCNBillboardConstraint()
                cloneTargetNode?.constraints = [billBoardConstraint]
                
                self.sceneView.scene.rootNode.addChildNode(cloneTargetNode ?? SCNNode())
                print("的を設置")
            }
        }
    }
    
    func vibration() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func setBulletsImageView(with image: UIImage?) {
        pistolBulletsCountImageView.image = image
    }
    
    func changeTargetsToTaimeisan() {
        
        self.sceneView.scene.rootNode.childNodes.forEach({ node in
            print("node: \(node), name: \(node.name)")
            if node.name == "target" {
                print("targetだった")
                while node.childNode(withName: "torus", recursively: false) != nil {
                    node.childNode(withName: "torus", recursively: false)?.removeFromParentNode()
                    print("torusを削除")
                }
                
                node.childNode(withName: "sphere", recursively: false)?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "taimei4.jpg")
                
            }else {
                print("targetじゃない")
            }
        })
        AudioModel.playSound(of: .kyuiin)
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
