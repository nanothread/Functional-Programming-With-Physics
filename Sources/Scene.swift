import SpriteKit

let sectionHeight: CGFloat = 100
let margin: CGFloat = 10
let gap: CGFloat = 70

class Scene: SKScene, SKPhysicsContactDelegate {
    private var rawSource: Source
    var ballSource: BallSource!
    var pipeline: [PipelineRepresentable]
    var contactObservers = [SKPhysicsContactDelegate]()
    
    init(size: CGSize, source: Source, pipeline: [PipelineRepresentable]) {
        self.rawSource = source
        self.pipeline = pipeline
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sceneDidLoad() {
        backgroundColor = .white
        
        physicsWorld.contactDelegate = self
        
        self.ballSource = BallSource(frame: CGRect(x: frame.minX,
                                                   y: frame.maxY - sectionHeight,
                                                   width: frame.width,
                                                   height: sectionHeight),
                                     source: rawSource)
        
        addChild(ballSource)
        
        for (index, pipe) in pipeline.enumerated() {
            let yOffset = CGFloat(index + 2) * sectionHeight
            
            if let map = pipe as? Map {
                drawMapSection(map: map, bottom: frame.maxY - yOffset, reversed: index % 2 == 1)
            }
            else if let filter = pipe as? Filter {
                drawFilterSection(filter: filter, bottom: frame.maxY - yOffset, reversed: index % 2 == 1)
            }
        }
        
        let yOffset = CGFloat(pipeline.count + 2) * sectionHeight
        let sink = Sink(frame: CGRect(x: 0, y: frame.maxY - yOffset, width: frame.width, height: sectionHeight),
                        reversed: !pipeline.count.isMultiple(of: 2))
        addChild(sink)
    }
    
    func reset() {
        ballSource.reset()
    }
    
    func drawMapSection(map: Map, bottom: CGFloat, reversed: Bool) {
        let trans: (CGFloat) -> CGFloat = { reversed ? (self.frame.maxX - $0) : $0 }
        
        // Slope
        addLine(start: CGPoint(x: trans(margin), y: bottom + 30),
                end: CGPoint(x: trans(margin + gap), y: bottom))
        
        // Base
        addLine(start: CGPoint(x: trans(margin + gap), y: bottom),
                end:  CGPoint(x: trans(frame.maxX - margin - gap), y: bottom))
        
        // Barrier
        addLine(start: CGPoint(x: trans(frame.maxX - margin), y: bottom),
                end: CGPoint(x: trans(frame.maxX - margin), y: bottom + 60))
        
        
        // Tunnel
        let tunnel = Tunnel(map: map,
                            frame: CGRect(x: frame.minX, y: bottom, width: frame.width, height: sectionHeight),
                            reversed: reversed)
        addChild(tunnel)
        contactObservers.append(tunnel)
    }
    
    func drawFilterSection(filter: Filter, bottom: CGFloat, reversed: Bool) {
        let trans: (CGFloat) -> CGFloat = { reversed ? (self.frame.maxX - $0) : $0 }
        
        // Slope
        addLine(start: CGPoint(x: trans(margin), y: bottom + 30),
                end: CGPoint(x: trans(margin + gap), y: bottom))
        
        // Base
        addLine(start: CGPoint(x: trans(margin + gap), y: bottom),
                end:  CGPoint(x: trans(frame.maxX - margin - gap), y: bottom))
        
        let decider = Decider(filter: filter,
                              frame: CGRect(x: frame.minX, y: bottom, width: frame.width, height: sectionHeight),
                              reversed: reversed)
        addChild(decider)
        contactObservers.append(decider)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        contactObservers.forEach { $0.didBegin?(contact) }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        contactObservers.forEach { $0.didEnd?(contact) }
    }
    
    func addLine(start: CGPoint, end: CGPoint, config: (SKShapeNode) -> Void = { _ in }) {
        let line = SKShapeNode.edge(from: start, to: end)
        config(line)
        addChild(line)
    }
    
    func releaseNextValue() {
        ballSource.releaseValue()
    }
}

