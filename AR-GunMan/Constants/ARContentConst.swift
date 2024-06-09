//
//  ARContentConst.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/05/09.
//

import Foundation
import SceneKit

final class ARContentConst {
    static let targetScnAssetsPath = "art.scnassets/Target/target.scn"
    static let pistolScnAssetsPath = "art.scnassets/Weapon/Pistol/pistol.scn"
    static let bazookaScnAssetsPath = "art.scnassets/Weapon/Bazooka/bazooka.scn"
    static let bazookaExplosionParticleScnAssetsPath = "art.scnassets/ParticleSystem/bazookaExplosion.scn"
    
    static let bazookaExplosionParticleBirthRate: CGFloat = 300
    static let bazookaExplosionTypeName = "bazookaExplosion"
    
    static let playerAnimationUpdateInterval: Double = 0.2
    
    static let targetNodeName = "target"
    static let bulletNodeName = "bullet"
    static let pistolParentNodeName = "pistolParent"
    static let bazookaParentNodeName = "bazookaParent"
    
    static let taimeiSanImageName = "taimei-san.jpg"
    
    static let originalBulletNode: SCNNode = {
        let sphere: SCNGeometry = SCNSphere(radius: 0.05)
        let customYellow = UIColor(red: 253/255, green: 202/255, blue: 119/255, alpha: 1)
        sphere.firstMaterial?.diffuse.contents = customYellow
        
        let bulletNode = SCNNode(geometry: sphere)
        bulletNode.scale = SCNVector3(x: 1, y: 1, z: 1)
        
        //当たり判定用のphysicBodyを追加
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        bulletNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        bulletNode.physicsBody?.contactTestBitMask = 1
        bulletNode.physicsBody?.isAffectedByGravity = false
        return bulletNode
    }()
    
    static let originalTargetNode: CustomSCNNode = {
        let originalTargetNode = CustomSCNNode(
            from: SceneNodeUtil.loadScnFile(
                of: ARContentConst.targetScnAssetsPath,
                nodeName: ARContentConst.targetNodeName
            ),
            gameObjectInfo: .init(type: .target)
        )
        
        originalTargetNode.scale = SCNVector3(0.3, 0.3, 0.3)
        
        let targetNodeGeometry = (originalTargetNode.childNode(withName: "sphere", recursively: false)?.geometry) ?? SCNGeometry()
        
        //MARK: - 当たり判定の肝2つ
        //①形状はラップしてる空のNodeではなく何か1つgeometryを持っているものにするを指定する
        //②当たり判定のscaleはoptions: [SCNPhysicsShape.Option.scale: SCNVector3]で明示的に設定する（大体①のgeometryの元となっているNodeのscaleを代入すれば等しい当たり判定になる）
        let shape = SCNPhysicsShape(geometry: targetNodeGeometry, options: [SCNPhysicsShape.Option.scale: originalTargetNode.scale])
        
        //当たり判定用のphysicBodyを追加
        originalTargetNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        originalTargetNode.physicsBody?.isAffectedByGravity = false
        
        return originalTargetNode
    }()
}
