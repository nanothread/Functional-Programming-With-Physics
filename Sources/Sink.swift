import SpriteKit

class Sink: SKNode {
    init(frame: CGRect, reversed: Bool) {
        let trans: (CGFloat) -> CGFloat = { reversed ? frame.width - $0 : $0 }
        
        super.init()
        self.position = frame.origin
        
        // Base
        addLine(start: CGPoint(x: trans(margin + gap), y: 0),
                end: CGPoint(x: trans(frame.maxX - margin), y: 0))
        
        // Slope
        addLine(start: CGPoint(x: trans(margin), y: 30),
                end: CGPoint(x: trans(margin + gap), y: 0))
        
        // Stopper
        addLine(start: CGPoint(x: trans(frame.width - margin), y: 0),
                end: CGPoint(x: trans(frame.width - margin), y: 60))
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
