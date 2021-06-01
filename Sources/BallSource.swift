import SpriteKit
import Combine

class BallSource: SKNode {
    private var balls = Set<Ball>()
    private var pendingBalls = [Ball]()
    private var source: Source
    private var size: CGSize
    
    private var cancellables = Set<AnyCancellable>()
    private var laser: SKShapeNode!
    
    private var isRotationEnabled: Bool = true {
        didSet { reset() }
    }
    
    func releaseValue() {
        guard !pendingBalls.isEmpty else { return }
        let ball = pendingBalls.removeFirst()
        ball.physicsBody?.collisions.remove(.laser)
        
        if let value = source.next() {
            let pos = CGPoint(x: size.width, y: size.height)
            addBall(at: pos, with: value)
        }
        
        laser.alpha = 0
        laser.yScale = 0
        laser.run(.group([
            .fadeIn(withDuration: 0.5),
            .scaleY(to: 1, duration: 0.5)
        ]))
    }
    
    func reset() {
        balls.forEach { $0.removeFromParent() }
        balls.removeAll()
        pendingBalls.removeAll()
        
        self.source.reset()
        setupBalls()
    }
    
    func setupBalls() {
        for (offset, value) in source.prefix(7).enumerated() {
            let pos = CGPoint(x: 80 + CGFloat(offset) * 50,
                              y: frame.height + 100)
            addBall(at: pos, with: value)
        }
    }
    
    func addBall(at pos: CGPoint, with value: Int) {
        let ball = Ball(position: pos, value: value)
        ball.physicsBody?.category = .ball
        ball.physicsBody?.collisions = [.ball, .hardEdge, .laser]
        ball.physicsBody?.contactTest = .invisibleEdge
        updateBallPhysics(ball: ball)
        addChild(ball)
        pendingBalls.append(ball)
        balls.insert(ball)
    }
    
    func updateBallPhysics(ball: Ball) {
        ball.physicsBody?.allowsRotation = isRotationEnabled
        ball.physicsBody?.friction = isRotationEnabled ? 0.2 : 0
        ball.physicsBody?.restitution = isRotationEnabled ? 0.2 : 0
        ball.physicsBody?.linearDamping = isRotationEnabled ? 0.1 : 0.25
        ball.zRotation = 0
    }
    
    init(frame: CGRect, source: Source) {
        self.source = source.makeIterator()
        self.size = frame.size
        
        super.init()
        self.position = frame.origin
        
        setupBalls()
                
        addLine(start: CGPoint(x: margin + gap, y: 0),
                end: CGPoint(x: frame.width * 2, y: frame.height))
        
        addLine(start: CGPoint(x: margin, y: 0),
                end: CGPoint(x: margin, y: frame.height))
        
        addLine(start: CGPoint(x: margin, y: 0),
                end: CGPoint(x: margin + gap, y: 0)) {
            $0.strokeColor = .red
            $0.physicsBody?.category = .laser
            self.laser = $0
        }
        
        EditorModel.shared.$isRotationEnabled
            .removeDuplicates()
            .assign(to: \.isRotationEnabled, on: self)
            .store(in: &cancellables)
    }
    
    func addLine(start: CGPoint, end: CGPoint, config: (SKShapeNode) -> Void = { _ in }) {
        let line = SKShapeNode.edge(from: start, to: end)
        config(line)
        addChild(line)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
