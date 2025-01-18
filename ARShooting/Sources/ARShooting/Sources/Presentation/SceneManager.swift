//
//  SceneManager.swift
//
//
//  Created by ウルトラ深瀬 on 19/12/24.
//

import ARKit

protocol SceneManagerInterface {
    var targetHit: (() -> Void)? { get set }
    func getSceneView() -> ARSCNView
    func runSession()
    func pauseSession()
    func showWeaponObject(weaponId: Int)
    func renderWeaponFiring()
    func changeTargetsAppearance(to imageName: String)
}

final class SceneManager: NSObject {
    var targetHit: (() -> Void)?
    private let sceneView: ARSCNView
    private var loadedWeaponDataList = [LoadedWeaponObjectData]()
    private let originalBulletNode = SceneNodeUtil.originalBulletNode()
    private var currentWeaponId: Int = 0
    
    init(frame: CGRect) {
        // MEMO: 予めframeを渡して初期化することで、モーダル出現アニメーションの途中時点から既に正しい比率でSceneオブジェクトを表示した状態で一緒にアニメーションさせられるので遷移の見た目が綺麗になる（遷移前に予め表示予定領域のframeが確定している場合）
        sceneView = ARSCNView(frame: frame)
        super.init()
        setup(targetCount: 50)
    }
    
    // MARK: Private Methods
    private func setup(targetCount: Int) {
        sceneView.scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        
        showTargetsToRandomPositions(count: targetCount)
    }
    
    private func showTargetsToRandomPositions(count: Int) {
        let originalTargetNode = SceneNodeUtil.originalTargetNode()
        
        DispatchQueue.main.async { [weak self] in
            Array(0..<count).forEach { _ in
                let clonedTargetNode = originalTargetNode.clone()
                clonedTargetNode.position = SceneNodeUtil.getRandomTargetPosition()
                SceneNodeUtil.addBillboardConstraint(clonedTargetNode)
                self?.sceneView.scene.rootNode.addChildNode(clonedTargetNode)
            }
        }
    }
    
    private func handleObjectLoadNecessity(objectData: WeaponObjectData) {
        // 既にロード済みのオブジェクトがある場合
        if let loadedWeaponData = loadedWeaponDataList.first(where: { $0.objectData.weaponId == objectData.weaponId }) {
            sceneView.scene.rootNode.addChildNode(loadedWeaponData.weaponParentNode)
        }
        // まだロード済のオブジェクトが無い場合
        else {
            let weaponParentNode = createWeaponNode(fileName: objectData.objectFileName, nodeName: objectData.rootObjectName)
            
            // Particle情報がある場合はロード
            let particleNode: SCNNode? = {
                if let particleFileName = objectData.targetHitParticleFileName,
                   let particleNodeName = objectData.targetHitParticleRootObjectName {
                    let particleNode = SceneNodeUtil.loadScnNode(fileName: particleFileName, nodeName: particleNodeName)
                    particleNode.particleSystems?.first?.birthRate = 0
                    return particleNode
                }else {
                    return nil
                }
            }()
            
            // 武器を持つ手の揺れのアニメーションが有効な場合は描画
            if objectData.isGunnerHandShakingAnimationEnabled {
                let weaponNode = weaponParentNode.childNode(withName: objectData.weaponObjectName, recursively: false) ?? SCNNode()
                weaponNode.runAction(SceneAnimationUtil.gunnerHandShakingAnimation)
            }
            
            let loadedWeaponData = LoadedWeaponObjectData(
                objectData: objectData,
                weaponParentNode: weaponParentNode,
                particleNode: particleNode
            )
            loadedWeaponDataList.append(loadedWeaponData)
            sceneView.scene.rootNode.addChildNode(loadedWeaponData.weaponParentNode)
        }
    }
    
    private func createWeaponNode(fileName: String, nodeName: String) -> SCNNode {
        let weaponParentNode = SceneNodeUtil.loadScnNode(fileName: fileName, nodeName: nodeName)
        SceneNodeUtil.addBillboardConstraint(weaponParentNode)
        weaponParentNode.position = SceneNodeUtil.getCameraPosition(sceneView)
        return weaponParentNode
    }
    
    private func removeOtherWeapons(except weaponId: Int) {
        loadedWeaponDataList.forEach { loadedWeaponData in
            if loadedWeaponData.objectData.weaponId != weaponId {
                loadedWeaponData.weaponParentNode.removeFromParentNode()
            }
        }
    }
    
    private func currentWeaponObjectData() -> LoadedWeaponObjectData? {
        return loadedWeaponDataList.first(where: { $0.objectData.weaponId == currentWeaponId })
    }
    
    private func currentWeaponNode() -> SCNNode {
        guard let currentObjectData = loadedWeaponDataList.first(where: { $0.objectData.weaponId == currentWeaponId }) else { return SCNNode() }
        return currentObjectData.weaponParentNode.childNode(withName: currentObjectData.objectData.weaponObjectName, recursively: false) ?? SCNNode()
    }
    
    private func renderTargetHitParticle(to position: SCNVector3) {
        if let particleNode = currentWeaponObjectData()?.particleNode {
            let clonedParticleNode = particleNode.clone()
            clonedParticleNode.position = position
            clonedParticleNode.particleSystems?.first?.birthRate = 300
            clonedParticleNode.particleSystems?.first?.loops = false
            sceneView.scene.rootNode.addChildNode(clonedParticleNode)
        }
    }
}

extension SceneManager: ARSCNViewDelegate {
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        currentWeaponObjectData()?.weaponParentNode.position = SceneNodeUtil.getCameraPosition(sceneView)
    }
}

extension SceneManager: SCNPhysicsContactDelegate {
    public func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        if contact.nodeA.name == "target" && contact.nodeB.name == "bullet"
            || contact.nodeB.name == "target" && contact.nodeA.name == "bullet" {
            targetHit?()
            
            renderTargetHitParticle(to: contact.contactPoint)
            
            contact.nodeA.removeFromParentNode()
            contact.nodeB.removeFromParentNode()
        }
    }
}

extension SceneManager: SceneManagerInterface {
    func getSceneView() -> ARSCNView {
        return sceneView
    }
    
    func runSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    func pauseSession() {
        sceneView.session.pause()
    }
    
    func showWeaponObject(weaponId: Int) {
        // weaponIdを使ってDataSourceから該当のWeaponObjectDataを取り出す
        let repository = WeaponRepository()
        do {
            let objectData = try repository.getWeaponObjectData(by: weaponId)
            currentWeaponId = objectData.weaponId
            removeOtherWeapons(except: objectData.weaponId)
            handleObjectLoadNecessity(objectData: objectData)
            
        } catch {
            print("getWeaponObjectData error: \(error)")
        }
    }
    
    func renderWeaponFiring() {
        // 弾の発射アニメーションを描画
        let clonedBulletNode = originalBulletNode.clone()
        clonedBulletNode.position = SceneNodeUtil.getCameraPosition(sceneView)
        sceneView.scene.rootNode.addChildNode(clonedBulletNode)
        clonedBulletNode.runAction(SceneAnimationUtil.bulletShootingAnimation(sceneView.pointOfView)) {
            clonedBulletNode.removeFromParentNode()
        }
        
        // 武器の反動アニメーションを描画
        if currentWeaponObjectData()?.objectData.isRecoilAnimationEnabled ?? false {
            currentWeaponNode().runAction(SceneAnimationUtil.recoilAnimation)
        }
    }
    
    func changeTargetsAppearance(to imageName: String) {
        sceneView.scene.rootNode.childNodes.forEach({ node in
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
}
