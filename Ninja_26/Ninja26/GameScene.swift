//
//  GameScene.swift
//  Ninja26
//
//  Created by Aluno a29580 Tmp on 20/03/2026.
//

import SpriteKit
import GameplayKit


struct Categoria {
    static let none : UInt32 = 0
    static let all : UInt32 = UInt32.max
    static let monster : UInt32 = 0b1 //1
    static let projectile : UInt32 = 0b10 //2
    static let player : UInt32 = 0b11 //3
}




class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player = SKSpriteNode (imageNamed: "player")
    var scoreLabel : SKLabelNode!
    var score : Int = 0
    var livesLabel : SKLabelNode!
    var lives : Int = 3
    
    override func didMove(to view: SKView) {
         
        // fundo do ecra
        backgroundColor = .white
        
        
        //Label score
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: size.width - 80, y: size.height - 80)
        addChild(scoreLabel)
        
        livesLabel = SKLabelNode(text: "Lives: 3")
        livesLabel.fontSize = 20
        livesLabel.fontColor = .black
        livesLabel.position = CGPoint(x: size.width * 0.1, y: size.height - 80)
        addChild(livesLabel)
                
        //posicao do sprite
        player.position = CGPoint(x: (size.width * 0.1) / 2, y: size.height / 2)
        
        // adiciona na cena
        addChild(player)
        
        // associar fisica ao player
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = Categoria.player
        player.physicsBody?.contactTestBitMask = Categoria.monster
        player.physicsBody?.collisionBitMask = Categoria.none
        
                       
        
        // fisicas cena
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                   SKAction.run(addMonster),
                   SKAction.wait(forDuration: 1,withRange: 0)
            ]
        )))
        
        addMonster()
        
        
    }
    
    func addMonster (){
        
        var monster = SKSpriteNode (imageNamed: "monster")
        
        //definir posiçap aleatoria
        let randomY = CGFloat.random(in: monster.size.height/2 ..< size.height - monster.size.height-2)
        monster.position = CGPoint(x: size.width-80, y: randomY)
        
        //adiciona a cena
        addChild(monster)
        
        // associar fisica ao monster
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
        monster.physicsBody?.isDynamic = true
        monster.physicsBody?.categoryBitMask = Categoria.monster
        monster.physicsBody?.contactTestBitMask = Categoria.player | Categoria.projectile
        monster.physicsBody?.collisionBitMask = Categoria.none
        
        let move = SKAction.move(to: CGPoint(x: -monster.size.width, y: randomY), duration: 2)
        
        monster.run(SKAction.sequence([move, SKAction.removeFromParent()]))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let touchLocation = touch.location(in: self)
        
        // Criar o projectile
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        let offset = touchLocation - player.position
        if offset.x < 0 {return}
        
        addChild(projectile)
        
        // associar fisica ao projecile
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = Categoria.projectile
        projectile.physicsBody?.contactTestBitMask = Categoria.monster
        projectile.physicsBody?.collisionBitMask = Categoria.none
        
        
        let direction = offset.normalize()
        let amount = direction * 1000
        let finalDestination = amount + projectile.position
        let move = SKAction.move(to: finalDestination, duration: 2.0)
        projectile.run(SKAction.sequence([move, SKAction.removeFromParent()]))
               

    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        //para garantir que a ordem da colisao na\o interessa
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // colisão projectile vs monster
        if firstBody.categoryBitMask == Categoria.monster &&
            secondBody.categoryBitMask == Categoria.projectile {
            
            if let monster = firstBody.node as? SKSpriteNode,
               let projectile = secondBody.node as? SKSpriteNode {
                
                score += 1
                scoreLabel.text = "Score: \(score)"
                monster.removeFromParent()
                projectile.removeFromParent()
                
                if score > 5 {
                    let reveal = SKTransition.flipVertical(withDuration: 0.5)
                    let gameover = GameOverScene(size: self.size, won: true)
                    self.view?.presentScene(gameover, transition: reveal)
                }
            }
            
        }
        else if firstBody.categoryBitMask == Categoria.monster &&
                    secondBody.categoryBitMask == Categoria.player{
            if let monster = firstBody.node as? SKSpriteNode{
                
                lives -= 1
                livesLabel.text = "Lives: \(lives)"
                monster.removeFromParent()
            }
        }
     
        print(firstBody, secondBody)
        
    }

}
