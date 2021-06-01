import SpriteKit

class Tunnel: SKNode, SKPhysicsContactDelegate {
    let areaWidth: CGFloat = 200
    let areaHeight: CGFloat = 80
    
    private let rect: SKShapeNode
    private let label: SKLabelNode
    private let map: Map
    
    private let startEdge: SKShapeNode
    private let endEdge: SKShapeNode
    
    private var ballsInside = [Ball]() {
        didSet {
            if let ball = ballsInside.first {
                updateExpressionText(input: ball.value)
            } else {
                updateExpressionText(input: nil)
            }
        }
    }
    
    func updateExpressionText(input: Int?) {
        if let input = input {
            label.text = map.expression.replacingOccurrences(of: "input", with: String(input))
        } else {
            label.text = map.expression
        }
    }
    
    func expressionResult(input: Int) -> Int {
        do {
            return Int(try map.evaluateExpression(withInput: input))
        }
        catch {
            print(error)
            return input
        }
    }
    
    init(map: Map, frame: CGRect, reversed: Bool) {
        self.map = map
        
        rect = SKShapeNode(rect: CGRect(x: frame.midX - areaWidth / 2, y: 0, width: areaWidth, height: areaHeight))
        
        label = SKLabelNode(text: map.expression)
        
        let leftX = frame.midX - areaWidth / 2
        let rightX = frame.midX + areaWidth / 2
        let startX = reversed ? rightX : leftX
        let endX = reversed ? leftX : rightX
        startEdge = SKShapeNode.invisibleEdge(from: CGPoint(x: startX, y: 0),
                                              to: CGPoint(x: startX, y: areaHeight))
        
        endEdge = SKShapeNode.invisibleEdge(from: CGPoint(x: endX, y: 0),
                                            to: CGPoint(x: endX, y: areaHeight))
        
        super.init()
        self.position = frame.origin
        
        rect.fillColor = UIColor.Semantic.mapBlock
        addChild(rect)
        
        label.fontName = UIFont.name(forStyle: .rounded, weight: .semibold)
        label.fontColor = .white
        label.position = CGPoint(x: frame.midX, y: 30)
        addChild(label)
        
        addChild(startEdge)
        addChild(endEdge)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if let ball = contact.getBall(fromCollisionWithEdge: startEdge) {
            ballsInside.append(ball)
        }
        else if let _ = contact.getBall(fromCollisionWithEdge: endEdge) {
            if !ballsInside.isEmpty {
                ballsInside.removeFirst()
            }
        }
    }
    func didEnd(_ contact: SKPhysicsContact) {
        if let ball = contact.getBall(fromCollisionWithEdge: startEdge) {
            ball.value = expressionResult(input: ball.value)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
