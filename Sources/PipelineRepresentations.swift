import Foundation

public protocol PipelineRepresentable {
    var expression: String { get }
}

extension PipelineRepresentable {
    var mathExpression: String {
        expression
            .replacingOccurrences(of: "is even", with: "% 2 == 0")
            .replacingOccurrences(of: "is odd", with: "% 2 == 1")
            .replacingOccurrences(of: "is negative", with: "< 0")
            .replacingOccurrences(of: "is positive", with: "> 0")
            .replacingOccurrences(of: "x", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .replacingOccurrences(of: "≠", with: "!=")
            .replacingOccurence(of: "is prime", withTransform: { "isPrime(\($0))" })
            .replacingOccurence(of: "is square", withTransform: { "isSquare(\($0))" })
    }
    
    func evaluateExpression(withInput input: Int) throws -> Double {
        let expression = Expression(
            mathExpression,
            options: .boolSymbols,
            constants: [
                "input": Double(input)
            ],
            symbols: [
                .infix("x"): { args in args[0] * args[1] },
                .function("isPrime", arity: 1): { $0[0].isPrime() ? 1 : 0 },
                .function("isSquare", arity: 1): { $0[0].isSquare() ? 1 : 0 },
            ]
        )
        
        return try expression.evaluate()
    }
}

public struct Map: PipelineRepresentable {
    public var expression: String
    
    public init(expression: String) {
        self.expression = expression
    }
}

public struct Filter: PipelineRepresentable {
    public var expression: String
    
    public init(expression: String) {
        self.expression = expression
    }
}
