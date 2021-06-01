import SpriteKit

class Ball: SKNode {
    private var circle: SKShapeNode
    private var label: SKLabelNode
    
    var value: Int {
        didSet {
            label.text = String(value)
        }
    }
    
    init(position: CGPoint, value: Int) {
        self.value = value
        
        circle = SKShapeNode(circleOfRadius: 30)
        circle.fillColor = UIColor.Semantic.ball
        
        label = SKLabelNode(text: String(value))
        label.fontName = UIFont.name(forStyle: .rounded, weight: .semibold)
        label.fontColor = UIColor.Semantic.ballValue
        label.position.y -= 12
                
        super.init()
        
        self.position = position
        
        addChild(circle)
        addChild(label)
        
        physicsBody = SKPhysicsBody(circleOfRadius: 30)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
