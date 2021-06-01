import SpriteKit

class Decider: SKNode, SKPhysicsContactDelegate {
    private let areaWidth: CGFloat = 200
    private let areaHeight: CGFloat = 80
    
    private let trapdoor: SKNode
    private let measureArea: SKShapeNode
    private let label: SKLabelNode
    
    private let startEdge: SKShapeNode
    private let endEdge: SKShapeNode
    private let filter: Filter
    
    private let greenLight: SKShapeNode
    private let redLight: SKShapeNode
    
    private let lightOffColour = UIColor.systemGray5
    private var allowedThrough: Bool = false {
        didSet {
            greenLight.fillColor = allowedThrough ? .green : lightOffColour
            redLight.fillColor = allowedThrough ? lightOffColour : .red
        }
    }
    
    private let isReversed: Bool
    
    private var ballsInside = [Ball]() {
        didSet {
            if let ball = ballsInside.first {
                updateExpressionText(input: ball.value)
            } else {
                updateExpressionText(input: nil)
            }
        }
    }
    
    init(filter: Filter, frame: CGRect, reversed: Bool) {
        self.filter = filter
        self.isReversed = reversed
        
        trapdoor = SKNode()
        measureArea = SKShapeNode(rect: CGRect(x: frame.midX - areaWidth / 2,
                                               y: 0,
                                               width: areaWidth,
                                               height: areaHeight))
        
        label = SKLabelNode(text: filter.expression)
        
        let leftX = frame.midX - areaWidth / 2
        let rightX = frame.midX + areaWidth / 2
        let startX = reversed ? rightX : leftX
        let endX = reversed ? leftX : rightX
        startEdge = SKShapeNode.invisibleEdge(from: CGPoint(x: startX, y: 0),
                                              to: CGPoint(x: startX, y: areaHeight))
        
        endEdge = SKShapeNode.invisibleEdge(from: CGPoint(x: endX, y: 0),
                                            to: CGPoint(x: endX, y: areaHeight))
        
        redLight = SKShapeNode(circleOfRadius: 5)
        greenLight = SKShapeNode(circleOfRadius: 5)
        
        super.init()
        self.position = frame.origin

        measureArea.fillColor = UIColor.Semantic.filterBlock
        addChild(measureArea)

        label.fontName = UIFont.name(forStyle: .rounded, weight: .semibold)
        label.fontColor = .white
        label.position = CGPoint(x: frame.midX, y: 30)
        addChild(label)
        
        
        let trapLine = SKShapeNode.edge(from: CGPoint(x: 0, y: 0),
                                        to:  CGPoint(x: reversed ? (gap-margin) : -(gap-margin), y: 0))
        trapdoor.addChild(trapLine)
        trapdoor.position = CGPoint(x: reversed ? margin : frame.maxX - margin, y: 0)
        addChild(trapdoor)
        
        addChild(startEdge)
        addChild(endEdge)
        
        redLight.position = CGPoint(x: margin + gap + 6, y: areaHeight)
        if !reversed { redLight.position.x = frame.maxX - redLight.position.x }
        redLight.fillColor = .red
        addChild(redLight)

        greenLight.position = CGPoint(x: margin + gap - 6, y: areaHeight)
        if !reversed { greenLight.position.x = frame.maxX - greenLight.position.x }
        greenLight.fillColor = lightOffColour
        addChild(greenLight)
    }
    
    func openTrapdoor() {
        trapdoor.removeAllActions()
        
        let mul: TimeInterval = EditorModel.shared.isSlowEnabled ? 0.5 : 1
        trapdoor.run(SKAction.sequence([
            SKAction.rotate(toAngle: isReversed ? .pi/2 : -.pi/2, duration: 0.25 / mul),
            SKAction.wait(forDuration: 0.75 / mul),
            SKAction.run { self.allowedThrough = false },
            SKAction.rotate(toAngle: 0, duration: 0.25 / mul),
        ]))
    }
    
    func updateExpressionText(input: Int?) {
        if let input = input {
            label.text = filter.expression.replacingOccurrences(of: "input", with: String(input)) + "?"
        } else {
            label.text = filter.expression
        }
    }
    
    func expressionResult(input: Int) -> Bool {
        do {
            let val = try filter.evaluateExpression(withInput: input)
            return val > 0
        }
        catch {
            print(error)
            return false
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if let ball = contact.getBall(fromCollisionWithEdge: startEdge) {
            if expressionResult(input: ball.value) {
                allowedThrough = true
            }
            ballsInside.append(ball)
        }
        else if let ball = contact.getBall(fromCollisionWithEdge: endEdge) {
            if expressionResult(input: ball.value) {
                openTrapdoor()
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        if contact.getBall(fromCollisionWithEdge: endEdge) != nil {
            if !ballsInside.isEmpty {
                ballsInside.removeFirst()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
