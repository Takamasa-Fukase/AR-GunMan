//
//  ARShootingController.swift
//  ARShootingLib
//
//  Created by ウルトラ深瀬 on 2026/05/29.
//

import ARKit

public protocol ARShootingControllerInterface: AnyObject {
    var targetHit: ((WeaponType) -> Void)? { get set }
    func runSession()
    func pauseSession()
    func showWeapon(of type: WeaponType)
    func renderWeaponFiring()
    func changeTargetsAppearance(to imageName: String)
}

final class ARShootingController: NSObject, ARShootingControllerInterface {
    let arView: ARSCNView
    var targetHit: ((WeaponType) -> Void)?
    
    private let originalBulletNode = SceneNodeUtil.originalBulletNode()
    private var loadedWeaponNodeDataList: [LoadedWeaponNodeData] = []
    private var currentWeaponType: WeaponType = .pistol
    private var currentDisplayingWeaponNodeData: LoadedWeaponNodeData? {
        return loadedWeaponNodeDataList.first(where: { $0.weaponType == currentWeaponType })
    }
    
    init(
        frame: CGRect,
        targetCount: Int
    ) {
        // MEMO: 予めframeを渡して初期化することで、
        // モーダル出現アニメーションの途中時点から既に正しい比率で
        // Sceneオブジェクトを表示した状態で一緒にアニメーションさせられるので
        // 遷移の見た目が綺麗になる（遷移前に予め表示予定領域のframeが確定している場合）
        arView = ARSCNView(frame: frame)
        super.init()
        setup(targetCount: targetCount)
    }
    
    func runSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        arView.session.run(configuration)
    }
    
    func pauseSession() {
        arView.session.pause()
    }
    
    func showWeapon(of type: WeaponType) {
        currentWeaponType = type
        
        // まだ3Dオブジェクト群（Node）をロードしていない場合
        if loadedWeaponNodeDataList.first(where: { $0.weaponType == type }) == nil {
            loadAndSetupWeaponObjects(
                weaponType: type,
                weaponResources: type.objectInfo.weaponResources,
                particleResources: type.objectInfo.particleResources,
                isGunnerHandShakingAnimationEnabled: type.objectInfo.isGunnerHandShakingAnimationEnabled
            )
        }
        
        removeOtherWeaponObjects(except: type)
        showWeaponObject(of: type)
    }
    
    func renderWeaponFiring() {
        // 弾の発射アニメーションを描画
        let clonedBulletNode = originalBulletNode.clone()
        clonedBulletNode.name = currentWeaponType.objectInfo.bulletName
        clonedBulletNode.position = SceneNodeUtil.getCameraPosition(arView)
        arView.scene.rootNode.addChildNode(clonedBulletNode)
        clonedBulletNode.runAction(SceneAnimationUtil.bulletShootingAnimation(arView.pointOfView)) {
            clonedBulletNode.removeFromParentNode()
        }
        
        // 武器の反動アニメーションを描画
        if currentWeaponType.objectInfo.isRecoilAnimationEnabled {
            currentDisplayingWeaponNodeData?.weaponNode.runAction(
                SceneAnimationUtil.recoilAnimation
            )
        }
    }
    
    func changeTargetsAppearance(to imageName: String) {
        arView.scene.rootNode.childNodes.forEach({ node in
            if node.name == "target" {
                while node.childNode(withName: "torus", recursively: false) != nil {
                    //ドーナツ型の白い線のパーツを削除
                    node.childNode(withName: "torus", recursively: false)?.removeFromParentNode()
                }
            }
            node.childNode(withName: "sphere", recursively: false)?
                .geometry?.firstMaterial?.diffuse.contents = UIImage(named: imageName, in: Bundle.module, with: nil)
        })
    }
    
    // MARK: Private Methods
    private func loadAndSetupWeaponObjects(
        weaponType: WeaponType,
        weaponResources: WeaponObjectResources,
        particleResources: TargetHitParticleResources?,
        isGunnerHandShakingAnimationEnabled: Bool
    ) {        // 武器の親Nodeと武器自体のNodeをロード
        let (weaponParentNode, weaponNode) = createWeaponNode(
            fileName: weaponResources.fileName,
            parentNodeName: weaponResources.parentObjectName,
            nodeName: weaponResources.objectName
        )
        
        // 武器を持つ手の揺れのアニメーションが有効な場合は描画
        if isGunnerHandShakingAnimationEnabled {
            weaponNode.runAction(SceneAnimationUtil.gunnerHandShakingAnimation)
        }
        
        // Particle情報がある場合はロード
        let targetHitParticleNode: SCNNode? = {
            if let particleResources = particleResources {
                let particleNode = SceneNodeUtil.loadScnNode(
                    fileName: particleResources.fileName,
                    nodeName: particleResources.objectName
                )
                particleNode.particleSystems?.first?.birthRate = 0
                return particleNode
            } else {
                return nil
            }
        }()
        
        // ロード済みの武器に関するパーツ群を1つの構造体にまとめて配列に保持
        let loadedWeaponNodeData = LoadedWeaponNodeData(
            weaponType: weaponType,
            weaponParentNode: weaponParentNode,
            weaponNode: weaponNode,
            targetHitParticleNode: targetHitParticleNode
        )
        loadedWeaponNodeDataList.append(loadedWeaponNodeData)
    }
    
    private func showWeaponObject(of type: WeaponType) {
        guard let loadedWeaponNodeData = loadedWeaponNodeDataList.first(where: { $0.weaponType == type }) else { return }
        arView.scene.rootNode.addChildNode(loadedWeaponNodeData.weaponParentNode)
    }
    
    private func removeOtherWeaponObjects(except type: WeaponType) {
        loadedWeaponNodeDataList.forEach { loadedWeaponNodeData in
            if loadedWeaponNodeData.weaponType != type {
                loadedWeaponNodeData.weaponParentNode.removeFromParentNode()
            }
        }
    }
    
    private func setup(targetCount: Int) {
        arView.scene = SCNScene()
        arView.autoenablesDefaultLighting = true
        arView.delegate = self
        arView.scene.physicsWorld.contactDelegate = self
        
        showTargetsToRandomPositions(count: targetCount)
    }
    
    private func showTargetsToRandomPositions(count: Int) {
        let originalTargetNode = SceneNodeUtil.originalTargetNode()
        
        DispatchQueue.main.async {
            Array(0..<count).forEach { _ in
                let clonedTargetNode = originalTargetNode.clone()
                clonedTargetNode.position = SceneNodeUtil.getRandomTargetPosition()
                SceneNodeUtil.addBillboardConstraint(clonedTargetNode)
                self.arView.scene.rootNode.addChildNode(clonedTargetNode)
            }
        }
    }
    
    private func createWeaponNode(
        fileName: String,
        parentNodeName: String,
        nodeName: String
    ) -> (parentNode: SCNNode, weaponNode: SCNNode) {
        let weaponParentNode = SceneNodeUtil.loadScnNode(fileName: fileName, nodeName: parentNodeName)
        SceneNodeUtil.addBillboardConstraint(weaponParentNode)
        weaponParentNode.position = SceneNodeUtil.getCameraPosition(arView)
        let weaponNode = weaponParentNode.childNode(withName: nodeName, recursively: false) ?? SCNNode()
        return (weaponParentNode, weaponNode)
    }
    
    private func renderTargetHitParticle(to position: SCNVector3) {
        if let particleNode = currentDisplayingWeaponNodeData?.targetHitParticleNode {
            let clonedParticleNode = particleNode.clone()
            clonedParticleNode.position = position
            clonedParticleNode.particleSystems?.first?.birthRate = 300
            clonedParticleNode.particleSystems?.first?.loops = false
            arView.scene.rootNode.addChildNode(clonedParticleNode)
        }
    }
}

extension ARShootingController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        currentDisplayingWeaponNodeData?.weaponParentNode.position = SceneNodeUtil.getCameraPosition(arView)
    }
}

extension ARShootingController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        // 的と弾の衝突であることを検証
        guard let targetNode = [contact.nodeA, contact.nodeB].first(where: { $0.name == "target" }),
              let bulletNode = [contact.nodeA, contact.nodeB].first(where: { ($0.name ?? "").contains("Bullet") }) else { return }
        // どの武器の弾かを判別
        guard let weaponType = WeaponType.allCases.first(where: { $0.objectInfo.bulletName == bulletNode.name }) else {
            fatalError("bulletNameが一致するWeaponTypeがありません")
        }
        
        // 弾がターゲットに命中したことを通知
        targetHit?(weaponType)
        
        // 着弾時の特殊効果（爆発など）を描画
        renderTargetHitParticle(to: contact.contactPoint)
        
        targetNode.removeFromParentNode()
        bulletNode.removeFromParentNode()
    }
}
