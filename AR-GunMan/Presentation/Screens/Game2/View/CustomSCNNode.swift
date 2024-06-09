//
//  CustomSCNNode.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 8/6/24.
//

import SceneKit

final class CustomSCNNode: SCNNode {
    private(set) var gameObjectInfo: GameObjectInfo
    
    override init() {
        self.gameObjectInfo = .init(type: .pistolBullet)
        super.init()
    }
    
    init(gameObjectInfo: GameObjectInfo) {
        self.gameObjectInfo = gameObjectInfo
        super.init()
    }
    
    init(with geometry: SCNGeometry?, gameObjectInfo: GameObjectInfo) {
        self.gameObjectInfo = gameObjectInfo
        super.init()
        self.geometry = geometry
    }
    
    init(from existingScnNode: SCNNode, gameObjectInfo: GameObjectInfo) {
        self.gameObjectInfo = gameObjectInfo
        super.init()
        self.geometry = existingScnNode.geometry
        self.name = existingScnNode.name
        self.position = existingScnNode.position
        self.rotation = existingScnNode.rotation
        self.scale = existingScnNode.scale
        self.transform = existingScnNode.transform
        existingScnNode.childNodes.forEach({ self.addChildNode($0) })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func clone() -> CustomSCNNode {
        let clonedNode = super.clone()
        clonedNode.setGameObjectInfo(.init(type: gameObjectInfo.type))
        return clonedNode
    }
    
    fileprivate func setGameObjectInfo(_ gameObjectInfo: GameObjectInfo) {
        self.gameObjectInfo = gameObjectInfo
    }
}
