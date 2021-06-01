import UIKit
import SpriteKit

extension UIFont {
    static func name(forStyle style: UIFontDescriptor.SystemDesign, weight: Weight) -> String {
        let systemFont = UIFont.systemFont(ofSize: 32, weight: weight)
        let descriptor = systemFont.fontDescriptor.withDesign(style)!
        let font = UIFont(descriptor: descriptor, size: 32)
        return font.fontName
    }
}

extension CGPath {
    static func line(from: CGPoint, to: CGPoint) -> CGPath {
        let path = CGMutablePath()
        path.move(to: from)
        path.addLine(to: to)
        return path
    }
}

extension SKShapeNode {
    static func edge(from start: CGPoint, to end: CGPoint) -> SKShapeNode {
        let path = CGPath.line(from: start, to: end)
        
        let line = SKShapeNode(path: path)
        line.strokeColor = .black
        line.lineWidth = 3
        line.physicsBody = SKPhysicsBody(edgeChainFrom: path)
        line.physicsBody?.category = .hardEdge
        line.lineCap = .round
        return line
    }

    static func invisibleEdge(from start: CGPoint, to end: CGPoint) -> SKShapeNode {
        let path = CGPath.line(from: start, to: end)
        let shape = SKShapeNode(path: path)
        shape.strokeColor = .clear
        shape.physicsBody = SKPhysicsBody(edgeChainFrom: path)
        shape.physicsBody?.category = .invisibleEdge
        return shape
    }
}

extension SKPhysicsContact {
    func getBall(fromCollisionWithEdge edge: SKShapeNode) -> Ball? {
        if bodyA.node == edge {
            return bodyB.node.flatMap { $0 as? Ball }
        }
        else if bodyB.node == edge {
            return bodyA.node.flatMap { $0 as? Ball }
        }
        return nil
    }
}

extension String {
    func replacingOccurence(of target: String, withTransform transform: (String) throws -> String) rethrows -> String {
        guard contains(target) else { return self }
        return try transform(self.replacingOccurrences(of: target, with: ""))
    }
}

extension Double {
    var isInteger: Bool {
        return self == Double(Int(self))
    }
    
    func isSquare() -> Bool {
        guard isInteger else { return false }
        return Int(self).isSquare()
    }
    
    func isPrime() -> Bool {
        guard isInteger else { return false }
        return Int(self).isPrime()
    }
}

public extension Int {
    func isSquare() -> Bool {
        guard self > 0 else { return false }
        return sqrt(Double(self)).isInteger
    }
    
    func isPrime() -> Bool {
        guard self > 1 else { return false }
        guard self > 3 else { return true }
        
        let n = Int(self)
        for i in 2...Int(sqrt(Double(self))) where n % i == 0 {
            return false
        }
        
        return true
    }
}

extension SKPhysicsBody {
    var category: Category {
        get { Category(rawValue: categoryBitMask) }
        set { categoryBitMask = newValue.rawValue }
    }
    
    var collisions: Category {
        get { Category(rawValue: collisionBitMask) }
        set { collisionBitMask = newValue.rawValue }
    }
    
    var contactTest: Category {
        get { Category(rawValue: contactTestBitMask) }
        set { contactTestBitMask = newValue.rawValue }
    }
}
