//
//  GameOverScene.swift
//  Ninja26
//
//  Created by Aluno a29580 Tmp on 25/03/2026.
//

import SpriteKit
import Foundation

class GameOverScene  : SKScene  {
    
    init(size: CGSize, won: Bool) {
        
        super.init(size: size)
        
        backgroundColor = .white
        let message = won ? "You win" : "Tou lost"
        let label = SKLabelNode(text: message)
        label.fontSize = 50
        label.fontColor = won ? .green : .red
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(label)
                
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
