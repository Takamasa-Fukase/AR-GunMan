//
//  GameViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/08/15.
//  Copyright © 2020 fukase. All rights reserved.
//

import UIKit
import FSPagerView
import PanModal
import RxSwift
import RxCocoa

class GameViewController: UIViewController {
    
    //MARK: - Properties
    let viewModel = GameViewModel()
    let sceneManager = GameSceneManager()
    let disposeBag = DisposeBag()

    @IBOutlet weak var bulletsCountImageView: UIImageView!
    @IBOutlet weak var sightImageView: UIImageView!
    @IBOutlet weak var timeCountLabel: UILabel!
    @IBOutlet weak var switchWeaponButton: UIButton!
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - input
        //CoreMotionで特定の加速度とジャイロイベントを検知した時にVMに通知
        CoreMotionUtil.getAccelerometer {
            self.viewModel.userShookDevide.onNext(Void())
        }
        CoreMotionUtil.getGyro {
            self.viewModel.userRotateDevice.onNext(Void())
        } secretEvent: {
            self.viewModel.userRotateDevice20Times.onNext(Void())
        }
                

        //MARK: - output
        let _ = viewModel.sightImage
            .bind(to: sightImageView.rx.image)
            .disposed(by: disposeBag)
        
        let _ = viewModel.bulletsCountImage
            .bind(to: bulletsCountImageView.rx.image)
            .disposed(by: disposeBag)
        
        let _ = viewModel.timeCountString
            .bind(to: timeCountLabel.rx.text)
            .disposed(by: disposeBag)

        let _ = viewModel.transitResultVC
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
//                let storyboard: UIStoryboard = UIStoryboard(name: "GameResultViewController", bundle: nil)
//                let vc = storyboard.instantiateViewController(withIdentifier: "GameResultViewController") as! GameResultViewController
//                self.present(vc, animated: true)
            }).disposed(by: disposeBag)
        
        
        //MARK: - other
        addSceneView()
        
        let _ = switchWeaponButton.rx.tap
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                let storyboard: UIStoryboard = UIStoryboard(name: "SwitchWeaponViewController", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "SwitchWeaponViewController") as! SwitchWeaponViewController
                vc.viewModel = self.viewModel
                self.present(vc, animated: true)
            }).disposed(by: disposeBag)
        


//
//
//        //ロケラン名中時の爆発
//
//        //art.scnassets配下のファイル名までのパスを記載
//        let explosionScene = SCNScene(named: "art.scnassets/ParticleSystems/ExplosionSamples/Explosion1.scn")
//
//        //注意: withNameにはscnのファイル名ではなく、Identity欄のnameを指定する
//        if let explosion = (explosionScene?.rootNode.childNode(withName: "Explosion1", recursively: false)) {
//
//            //座標を指定したい場合はここで設定（↓ではカメラ位置よりも50cm前方を指定）
//            let cameraPos = self.sceneView.pointOfView?.position ?? SCNVector3()
//            explosion.position = SCNVector3(x: cameraPos.x, y: cameraPos.y, z: cameraPos.z - 0.5)
//
//            //画面に反映
//            self.sceneView.scene.rootNode.addChildNode(explosion)
//
//        }
//
//        //ParticleSystemへのアクセス方法
//        sceneView.scene.rootNode.childNode(withName: "Explosion1", recursively: false)?.particleSystems?.first
//
//
//
//        if let particleSystem = sceneView.scene.rootNode.childNode(withName: "bazookaHitExplosion\(explosionCount)", recursively: false)?.particleSystems?.first  {
//
//            particleSystem.birthRate = 300
//            particleSystem.loops = false
//
//        }
//
//        exploPar = bazookaHitExplosion?.particleSystems?.first!
//
//        timeCountLabel.font = timeCountLabel.font.monospacedDigitFont
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SceneViewSettingUtil.startSession(sceneManager.sceneView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //初回のみチュートリアルを表示するのでチェック
        checkTutorialSeenStatus()
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        SceneViewSettingUtil.pauseSession(sceneManager.sceneView)
    }
    
    private func addSceneView() {
        sceneManager.sceneView.frame = view.frame
        view.insertSubview(sceneManager.sceneView, at: 0)
//        view.addSubview(sceneManager.sceneView)
//        view.bringSubviewToFront(switchWeaponButton)
    }
    
    private func checkTutorialSeenStatus() {
        if UserDefaultsUtil.isTutorialAlreadySeen() {
            viewModel.tutorialEnded.onNext(Void())
            
        }else {
            let storyboard: UIStoryboard = UIStoryboard(name: "TutorialViewController", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
            vc.delegate = self
            self.present(vc, animated: true)
        }
    }
    
//    func fireWeapon() {
//        guard isShootEnabled else {return}
//
//        switch currentWeapon {
//        case .pistol:
//
//            if pistolBulletsCount > 0 {
//                pistolBulletsCount -= 1
//
//                addBullet()
//                shootBullet()
//                print("shoot")
//
//                AudioUtil.playSound(of: .pistolShoot)
//
//            }else if pistolBulletsCount <= 0 {
//                AudioUtil.playSound(of: .pistolOutBullets)
//            }
//            print("ピストルの残弾数: \(pistolBulletsCount) / 7発")
//            setBulletsImageView(with: UIImage(named: "bullets\(pistolBulletsCount)"))
//
//        case .bazooka:
//
//            if bazookaRocketCount > 0 {
//
//                bazookaRocketCount -= 1
//
//                addBullet()
//                shootBullet()
//                print("shootRocket")
//
//                AudioUtil.playSound(of: .bazookaShoot)
//                AudioUtil.playSound(of: .bazookaReload)
//            }
//            print("ロケランの残弾数: \(bazookaRocketCount) / 1発")
//            setBulletsImageView(with: UIImage(named: "bazookaRocket\(bazookaRocketCount)"))
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
//                self.bazookaRocketCount = 1
//                print("ロケランの残弾数: \(self.bazookaRocketCount) / 1発")
//                self.setBulletsImageView(with: UIImage(named: "bazookaRocket\(self.bazookaRocketCount)"))
//            }
//
//        default:
//            break
//        }
//    }
//
//    func reloadPistol() {
//
//        guard isShootEnabled else {return}
//
//        if currentWeapon == .pistol {
//
//            pistolBulletsCount = 7
//            AudioUtil.playSound(of: .pistolReload)
//            print("ピストルの弾をリロードしました  残弾数: \(pistolBulletsCount)発")
//
//            setBulletsImageView(with: UIImage(named: "bullets\(pistolBulletsCount)"))
//        }
//
//    }


    //常に更新され続けるdelegateメソッド
//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        //現在表示中の武器をラップしている空のオブジェクトを常にカメラと同じPositionに移動させ続ける（それにより武器が常にFPS位置に保たれる）
//        if let pistol = sceneView.scene.rootNode.childNode(withName: "parent", recursively: false) {
//            pistol.position = sceneView.pointOfView?.position ?? SCNVector3()
//        }
//        if let bazooka = sceneView.scene.rootNode.childNode(withName: "bazookaParent", recursively: false) {
//            bazooka.position = sceneView.pointOfView?.position ?? SCNVector3()
//        }
//        if let rifle = sceneView.scene.rootNode.childNode(withName: "AKM_parent", recursively: false) {
//            rifle.position = sceneView.pointOfView?.position ?? SCNVector3()
//        }
//
//        if toggleActionInterval <= 0 {
//            guard let currentPos = sceneView.pointOfView?.position else {return}
//            let diff = SCNVector3Make(lastCameraPos.x - currentPos.x, lastCameraPos.y - currentPos.y, lastCameraPos.z - currentPos.z)
//            let distance = sqrt((diff.x * diff.x) + (diff.y * diff.y) + (diff.z * diff.z))
////            print("0.2秒前からの移動距離: \(String(format: "%.1f", distance))m")
//
//            isPlayerRunning = (distance >= 0.15)
//
//            if isPlayerRunning != lastPlayerStatus {
//
//                switch currentWeapon {
//                case .pistol:
//                    sceneView.scene.rootNode.childNode(withName: "parent", recursively: false)?.childNode(withName: "M1911_a", recursively: false)?.removeAllActions()
//                    sceneView.scene.rootNode.childNode(withName: "parent", recursively: false)?.childNode(withName: "M1911_a", recursively: false)?.position = SCNVector3(0.17, -0.197, -0.584)
//                    sceneView.scene.rootNode.childNode(withName: "parent", recursively: false)?.childNode(withName: "M1911_a", recursively: false)?.eulerAngles = SCNVector3(-1.4382625, 1.3017014, -2.9517007)
//                case .rifle:
//
//                    sceneView.scene.rootNode.childNode(withName: "AKM_parent", recursively: false)?.childNode(withName: "AKM", recursively: false)?.removeAllActions()
//                    sceneView.scene.rootNode.childNode(withName: "AKM_parent", recursively: false)?.childNode(withName: "AKM", recursively: false)?.position = SCNVector3(0, 0, 0)
//                    sceneView.scene.rootNode.childNode(withName: "AKM_parent", recursively: false)?.childNode(withName: "AKM", recursively: false)?.eulerAngles = SCNVector3(0, 0, 0)
//
//                default: break
//                }
//
//                isPlayerRunning ? gunnerShakeAnimationRunning() : gunnerShakeAnimationNormal()
//            }
//            self.toggleActionInterval = 0.2
//            lastCameraPos = sceneView.pointOfView?.position ?? SCNVector3()
//            lastPlayerStatus = isPlayerRunning
//        }
//        toggleActionInterval -= 0.02
//    }
    
//    func gunnerShakeAnimationNormal() {
//
//        //銃の先端が上に跳ね上がる回転のアニメーション
//        let rotate = SCNAction.rotateBy(x: -0.1779697224, y: 0.0159312604, z: -0.1784194, duration: 1.2)
//        //↑の逆（下に戻る回転）
//        let rotateReverse = rotate.reversed()
//        //上下のアニメーションを直列に実行するアニメーション
//        let rotateAction = SCNAction.sequence([rotate, rotateReverse])
//
//
//        //銃が垂直に持ち上がるアニメーション
//        let moveUp = SCNAction.moveBy(x: 0, y: 0.01, z: 0, duration: 0.8)
//        //↑の逆（垂直に下に下がる）
//        let moveDown = moveUp.reversed()
//        //上下のアニメーションを直列に実行するアニメーション
//        let moveAction = SCNAction.sequence([moveUp, moveDown])
//
//
//        //回転と上下移動のアニメーションを並列に同時実行するアニメーション(それぞれのdurationをずらすことによって不規則な動き感を出している)
//        let conbineAction = SCNAction.group([rotateAction, moveAction])
//
//        //↑を永遠繰り返すアニメーション
//        let gunnerShakeAction = SCNAction.repeatForever(conbineAction)
//
//        //実行
//        sceneView.scene.rootNode.childNode(withName: "parentNode", recursively: false)?.childNode(withName: "M1911", recursively: false)?.runAction(gunnerShakeAction)
//
//
//    }
    
//    func gunnerShakeAnimationRunning() {
//        //銃が右に移動するアニメーション
//        let moveRight = SCNAction.moveBy(x: 0.03, y: 0, z: 0, duration: 0.3)
//        //↑の逆（左に移動）
//        let moveLeft = moveRight.reversed()
//
//        //銃が垂直に持ち上がるアニメーション
//        let moveUp = SCNAction.moveBy(x: 0, y: 0.02, z: 0, duration: 0.15)
//        //↑の逆（垂直に下に下がる）
//        let moveDown = moveUp.reversed()
//        //上下交互
//        let upAndDown = SCNAction.sequence([moveUp, moveDown])
//
//        let rightAndUpDown = SCNAction.group([moveRight, upAndDown])
//        let LeftAndUpDown = SCNAction.group([moveLeft, upAndDown])
//
//        //回転と上下移動のアニメーションを並列に同時実行するアニメーション(それぞれのdurationをずらすことによって不規則な動き感を出している)
//        let conbineAction = SCNAction.sequence([rightAndUpDown, LeftAndUpDown])
//
//        //↑を永遠繰り返すアニメーション
//        let repeatAction = SCNAction.repeatForever(conbineAction)
//
//        //実行
////        switch currentWeapon {
////        case .pistol:
////            sceneView.scene.rootNode.childNode(withName: "parent", recursively: false)?.childNode(withName: "M1911_a", recursively: false)?.runAction(repeatAction)
////        default: break
////        }
//    }
//
//    func shootingAnimation() {
//        //発砲時に銃の先端が上に跳ね上がる回転のアニメーション
//        let rotateAction = SCNAction.rotateBy(x: -0.9711356901, y: -0.08854044763, z: -1.013580166, duration: 0.1)
//        //↑の逆（下に戻る回転）
//        let reverse = rotateAction.reversed()
//        //上下のアニメーションを直列に実行するアニメーション
//        let shoot = SCNAction.sequence([rotateAction, reverse])
//
//        //実行
//        sceneView.scene.rootNode.childNode(withName: "parent", recursively: false)?.childNode(withName: "M1911_a", recursively: false)?.runAction(shoot)
//    }
//
//    //衝突検知時に呼ばれる
//    //MEMO: - このメソッド内でUIの更新を行いたい場合はmainThreadで行う
//    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
//        let nodeA = contact.nodeA
//        let nodeB = contact.nodeB
//
//        if (nodeA.name == "bullet" && nodeB.name == "target") || (nodeB.name == "bullet" && nodeA.name == "target") {
//            print("当たった")
//            AudioUtil.playSound(of: .headShot)
//            nodeA.removeFromParentNode()
//            nodeB.removeFromParentNode()
//
//            if currentWeapon == .bazooka {
//                AudioUtil.playSound(of: .bazookaHit)
//
//                if let first = sceneView.scene.rootNode.childNode(withName: "bazookaHitExplosion\(explosionCount)", recursively: false)?.particleSystems?.first  {
//
//                    first.birthRate = 300
//                    first.loops = false
//
//                }
//            }
//
//            switch currentWeapon {
//            case .pistol:
//                pistolPoint += 5
//            case .bazooka:
//                bazookaPoint += 12
//            default:
//                break
//            }
//
//            targetCount -= 1
//        }
//    }
//
    
}

extension GameViewController: TutorialVCDelegate {
    func tutorialEnded() {
        viewModel.tutorialEnded.onNext(Void())
    }
}

extension GameViewController {
    
//    func addPistol(shouldPlayPistolSet: Bool = true) {
//        //バズーカを削除
//        if let bazooka = self.sceneView.scene.rootNode.childNode(withName: "bazookaParent", recursively: false) {
//            print("bazookaを削除しました")
//            bazooka.removeFromParentNode()
//        } else if let rifle = self.sceneView.scene.rootNode.childNode(withName: "AKM_parent", recursively: false) {
//            print("rifleを削除しました")
//            rifle.removeFromParentNode()
//        }
//        let scene = SCNScene(named: "art.scnassets/Weapon/Pistol/M1911_a.scn")
//        //注意:scnのファイル名ではなく、Identity欄のnameを指定する
//        let parentNode = (scene?.rootNode.childNode(withName: "parent", recursively: false))!
//
//        let billBoardConstraint = SCNBillboardConstraint()
//        parentNode.constraints = [billBoardConstraint]
//
//        parentNode.position = sceneView.pointOfView?.position ?? SCNVector3()
//        self.sceneView.scene.rootNode.addChildNode(parentNode)
//
//        if shouldPlayPistolSet {
//            //チャキッ　の再生
//            AudioUtil.playSound(of: .pistolSet)
//        }
//
//        gunnerShakeAnimationNormal()
//    }
    
//    func addBazooka() {
//        //ピストルを削除
//        if let pistol = self.sceneView.scene.rootNode.childNode(withName: "parent", recursively: false) {
//            print("pistolを削除しました")
//            pistol.removeFromParentNode()
//        } else if let rifle = self.sceneView.scene.rootNode.childNode(withName: "AKM_parent", recursively: false) {
//            print("rifleを削除しました")
//            rifle.removeFromParentNode()
//        }
//        let scene = SCNScene(named: "art.scnassets/Weapon/RocketLauncher/bazooka2.scn")
//        //注意:scnのファイル名ではなく、Identity欄のnameを指定する
//        let bazooka = (scene?.rootNode.childNode(withName: "bazookaParent", recursively: false))!
//
//        let billBoardConstraint = SCNBillboardConstraint()
//        bazooka.constraints = [billBoardConstraint]
//
//        bazooka.position = sceneView.pointOfView?.position ?? SCNVector3()
//        self.sceneView.scene.rootNode.addChildNode(bazooka)
//
//        //チャキッ　の再生
//        AudioUtil.playSound(of: .bazookaSet)
//
//        gunnerShakeAnimationNormal()
//    }
//
//    func addRifle() {
//        //ピストルを削除
//        if let detonator = self.sceneView.scene.rootNode.childNode(withName: "parent", recursively: false) {
//            print("pistolを削除しました")
//            detonator.removeFromParentNode()
//        } else if let detonator = self.sceneView.scene.rootNode.childNode(withName: "bazookaParent", recursively: false) {
//            print("bazookaを削除しました")
//            detonator.removeFromParentNode()
//        }
//        let scene = SCNScene(named: "art.scnassets/Weapon/Rifle/AKM.scn")
//        //注意:scnのファイル名ではなく、Identity欄のnameを指定する
//        let rifle = (scene?.rootNode.childNode(withName: "AKM_parent", recursively: false))!
//
//        let billBoardConstraint = SCNBillboardConstraint()
//        rifle.constraints = [billBoardConstraint]
//
//        rifle.position = sceneView.pointOfView?.position ?? SCNVector3()
//        self.sceneView.scene.rootNode.addChildNode(rifle)
//
//        //チャキッ　の再生
//        AudioUtil.playSound(of: .pistolSet)
//
//        gunnerShakeAnimationNormal(5)
//    }
    
//    //弾ノードを設置
//    func addBullet() {
//        guard let cameraPos = sceneView.pointOfView?.position else {return}
//
//        let sphere: SCNGeometry = SCNSphere(radius: 0.05)
//        let customYellow = UIColor(red: 253/255, green: 202/255, blue: 119/255, alpha: 1)
//
//        sphere.firstMaterial?.diffuse.contents = customYellow
//        bulletNode = SCNNode(geometry: sphere)
//        guard let bulletNode = bulletNode else {return}
//        bulletNode.name = "bullet"
//        bulletNode.scale = SCNVector3(x: 1, y: 1, z: 1)
//        bulletNode.position = cameraPos
//
//        //当たり判定用のphysicBodyを追加
//        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
//        bulletNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
//        bulletNode.physicsBody?.contactTestBitMask = 1
//        bulletNode.physicsBody?.isAffectedByGravity = false
//
//        if currentWeapon == .bazooka {
//            explosionCount += 1
//
//            var parti: SCNParticleSystem? = SCNParticleSystem()
//            parti?.loops = true
//
//            parti = exploPar
//
//            parti?.loops = true
//
//            if let par = parti {
//
//                par.birthRate = 0
//                let node = SCNNode()
//                node.addParticleSystem(par)
//                node.name = "bazookaHitExplosion\(explosionCount)"
//                node.position = cameraPos
//                sceneView.scene.rootNode.addChildNode(node)
//            }
//
//        }
//
//        sceneView.scene.rootNode.addChildNode(bulletNode)
//
//        print("弾を設置")
//    }
//
//    //弾ノードを発射
//    func shootBullet() {
//        guard let camera = sceneView.pointOfView else {return}
//        let targetPosCamera = SCNVector3(x: camera.position.x, y: camera.position.y, z: camera.position.z - 10)
//        //カメラ座標をワールド座標に変換
//        let target = camera.convertPosition(targetPosCamera, to: nil)
//        let action = SCNAction.move(to: target, duration: TimeInterval(1))
//        bulletNode?.runAction(action, completionHandler: {
//            self.bulletNode?.removeFromParentNode()
//        })
//
//        if currentWeapon == .bazooka {
//
//            sceneView.scene.rootNode.childNode(withName: "bazookaHitExplosion\(explosionCount)", recursively: false)?.runAction(action)
//
//        }
//
//        shootingAnimation()
//
//        print("弾を発射")
//    }
//

//
//    func setBulletsImageView(with image: UIImage?) {
//        pistolBulletsCountImageView.image = image
//    }
//
//    func changeTargetsToTaimeisan() {
//
//        self.sceneView.scene.rootNode.childNodes.forEach({ node in
//            print("node: \(node), name: \(node.name)")
//            if node.name == "target" {
//                print("targetだった")
//                while node.childNode(withName: "torus", recursively: false) != nil {
//                    node.childNode(withName: "torus", recursively: false)?.removeFromParentNode()
//                    print("torusを削除")
//                }
//
//                node.childNode(withName: "sphere", recursively: false)?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "taimei4.jpg")
//
//            }else {
//                print("targetじゃない")
//            }
//        })
//        AudioUtil.playSound(of: .kyuiin)
//    }
}
