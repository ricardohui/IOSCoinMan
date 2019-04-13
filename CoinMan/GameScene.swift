//
//  GameScene.swift
//  CoinMan
//
//  Created by Ricardo Hui on 12/4/2019.
//  Copyright © 2019 Ricardo Hui. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var coinMan : SKSpriteNode?
    private var coinTimer : Timer?
    var bombTimer  : Timer?

    var ceil: SKSpriteNode?
    var scoreLabel: SKLabelNode?
    var yourScoreLabel : SKLabelNode?
    var finalScoreLabel : SKLabelNode?
    var score = 0;
    let coinManCategory : UInt32 = 0x1 << 1
    let coinCategory: UInt32 = 0x1 << 2
    let bombCategory: UInt32 = 0x1 << 3
    let groundAndCeilCategory : UInt32 = 0x1 << 4
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        physicsWorld.contactDelegate = self
        coinMan = childNode(withName: "CoinMan") as? SKSpriteNode
        coinMan?.physicsBody?.categoryBitMask = coinManCategory;
        coinMan?.physicsBody?.contactTestBitMask  = coinCategory | bombCategory
        coinMan?.physicsBody?.collisionBitMask = groundAndCeilCategory
        
        var coinManRun : [SKTexture] = []
        for number in 1...5{
            coinManRun.append(SKTexture(imageNamed: "frame-\(number)"))
        }
        coinMan?.run(SKAction.repeatForever(SKAction.animate(with: coinManRun, timePerFrame: 0.2)))
        

        
        
        ceil = childNode(withName: "ceil") as? SKSpriteNode
        ceil?.physicsBody?.categoryBitMask = groundAndCeilCategory
        ceil?.physicsBody?.collisionBitMask = coinManCategory
        
        
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        startTimer()
        createGrass()
        
    }
    
    func createGrass(){
        let sizingGrass = SKSpriteNode(imageNamed: "grass")
        let numberOfGrass = Int(size.width / sizingGrass.size.width) + 1
        for number in 0...numberOfGrass{
            let grass = SKSpriteNode(imageNamed: "grass")
            grass.physicsBody = SKPhysicsBody(rectangleOf: grass.size)
            grass.physicsBody?.categoryBitMask = groundAndCeilCategory
            grass.physicsBody?.collisionBitMask = coinManCategory
            grass.physicsBody?.affectedByGravity = false;
            grass.physicsBody?.isDynamic = false
            addChild(grass)
            
            let grassX = -size.width / 2 + grass.size.width / 2 + grass.size.width * CGFloat(number)
            grass.position = CGPoint(x:grassX, y: -size.height / 2 + grass.size.height / 2 - 18)
            
            let speed = 100.0
            
            let firstMoveLeft = SKAction.moveBy(x: -grass.size.width - grass.size.width * CGFloat(number), y: 0, duration: TimeInterval(grass.size.width + grass.size.width * CGFloat(number)) / speed)
            
            
            let resetGrass = SKAction.moveBy(x: size.width + grass.size.width, y: 0, duration: 0)
            
            let grassFullMove  = SKAction.moveBy(x: -size.width - grass.size.width, y: 0, duration: TimeInterval(size.width + grass.size.width) / speed)
            
            let grassMovingForever = SKAction.repeatForever(SKAction.sequence([grassFullMove,resetGrass]))
            
            grass.run(SKAction.sequence([firstMoveLeft, resetGrass, grassMovingForever]))
            
        }
        
    }
    
    func startTimer(){
        
        coinTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.createCoin()
        })
        bombTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
            self.createBomb()
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if scene?.isPaused == false{
            coinMan?.physicsBody?.applyForce(CGVector(dx: 0, dy: 10000))
        }
        
        
        let touch = touches.first
        if let location = touch?.location(in: self){
            let theNodes = nodes(at: location)
            
            for node in theNodes{
                if node.name == "play"{
                    //restart the game
                    score = 0
                    node.removeFromParent()
                    finalScoreLabel?.removeFromParent()
                    yourScoreLabel?.removeFromParent()
                    scene?.isPaused = false
                    scoreLabel?.text = "Score: \(score)"
                    startTimer()
                }
            }
        }
        
        
        
        
        
        
    }
    
    func createCoin(){
        let coinNode  = SKSpriteNode(imageNamed: "coin")
        coinNode.physicsBody = SKPhysicsBody(rectangleOf: coinNode.size)
        coinNode.size = CGSize(width: 80, height: 80)
        coinNode.physicsBody?.affectedByGravity = false
        coinNode.physicsBody?.categoryBitMask = coinCategory
        coinNode.physicsBody?.contactTestBitMask = coinManCategory
        coinNode.physicsBody?.collisionBitMask = 0
        addChild(coinNode)
        
            let sizingGrass = SKSpriteNode(imageNamed: "grass")
        
        
        let maxY = size.height / 2 - coinNode.size.height / 2
        let minY = -size.height / 2 - coinNode.size.height / 2 + sizingGrass.size.height
        let range = maxY - minY
        let bombY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        
        coinNode.position = CGPoint(x: size.width / 2 + coinNode.size.width / 2, y: bombY )
        let moveLeft = SKAction.moveBy(x: -size.width - coinNode.size.width, y: 0, duration: 2)
        coinNode.run(SKAction.sequence([moveLeft,SKAction.removeFromParent()]))
    }
    
    func createBomb(){
        let bombNode  = SKSpriteNode(imageNamed: "bomb")
        bombNode.size = CGSize(width: 100, height: 100)
        bombNode.physicsBody = SKPhysicsBody(rectangleOf: bombNode.size)
        bombNode.physicsBody?.affectedByGravity = false
        bombNode.physicsBody?.categoryBitMask = bombCategory
        bombNode.physicsBody?.contactTestBitMask = coinManCategory
        bombNode.physicsBody?.collisionBitMask = 0
        addChild(bombNode)
        
            let sizingGrass = SKSpriteNode(imageNamed: "grass")
        
        let maxY = size.height / 2 - bombNode.size.height / 2
        let minY = -size.height / 2 - bombNode.size.height / 2 + sizingGrass.size.height
        let range = maxY - minY
        let coinY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        
        bombNode.position = CGPoint(x: size.width / 2 + bombNode.size.width / 2, y: coinY )
        let moveLeft = SKAction.moveBy(x: -size.width - bombNode.size.width, y: 0, duration: 2)
        bombNode.run(SKAction.sequence([moveLeft,SKAction.removeFromParent()]))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == coinCategory{
            score += 1
            scoreLabel?.text = "Score: \(score)"
            contact.bodyA.node?.removeFromParent()
        }
        
        if contact.bodyB.categoryBitMask == coinCategory{
            score += 1
            scoreLabel?.text = "Score: \(score)"
            contact.bodyB.node?.removeFromParent()
        }
        if contact.bodyA.categoryBitMask == bombCategory{
            contact.bodyA.node?.removeFromParent()
            gameOver()
            print("Game Over")
        }
        if contact.bodyB.categoryBitMask == bombCategory{
            contact.bodyB.node?.removeFromParent()
            gameOver()
            print("Game Over")
        }
    }
    
    func gameOver(){
        scene?.isPaused = true
        
        coinTimer?.invalidate()
        bombTimer?.invalidate()
        
        yourScoreLabel = SKLabelNode(text:"Your Score:")
        yourScoreLabel?.position = CGPoint(x: 0, y: 200)
        yourScoreLabel?.zPosition = 1
        yourScoreLabel?.fontSize = 100
        if yourScoreLabel != nil{
            addChild(yourScoreLabel!)
        }
        
        
        finalScoreLabel = SKLabelNode(text:"\(score)")
        finalScoreLabel?.position = CGPoint(x: 0, y: 0)
        finalScoreLabel?.zPosition = 1
        finalScoreLabel?.fontSize = 200
        if finalScoreLabel != nil{
            addChild(finalScoreLabel!)
        }
        
        
        
        let playButton = SKSpriteNode(imageNamed: "play")
        playButton.position = CGPoint(x: 0, y: -200)
        playButton.zPosition = 1
        playButton.name = "play"
        addChild(playButton)
    }
}
