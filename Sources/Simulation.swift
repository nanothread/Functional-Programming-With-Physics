import SpriteKit
import UIKit
import SwiftUI
import Combine

public class Simulation: UIViewController {
    private let rawSequence: AnySequence<Int>
    private let pipeline: [PipelineRepresentable]
    private let editorModel = EditorModel.shared
    private var scene: Scene!
    
    private let width: CGFloat = 500
    private let controlHeight: CGFloat = 100
    private var simulationHeight: CGFloat {
        CGFloat(pipeline.count + 2) * sectionHeight + 10
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private let releaseThrottleRate: TimeInterval = 1
    private var canRelease = true
    
    public override func loadView() {
        self.view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: simulationHeight + controlHeight))
    }
    
    public init<S: Sequence>(source: S, pipeline: [PipelineRepresentable]) where S.Element == Int {
        self.rawSequence = AnySequence(source)
        self.pipeline = pipeline
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func releaseValue() {
        guard canRelease else { return }
        scene.releaseNextValue()
        canRelease = false
        DispatchQueue.main.asyncAfter(deadline: .now() + releaseThrottleRate) { [weak self] in
            self?.canRelease = true
        }
    }

    public override func viewDidLoad() {
        let skView = SKView(frame: CGRect(x: 0, y: 0, width: width, height: simulationHeight))
        view.addSubview(skView)
        
        scene = Scene(
            size: skView.frame.size,
            source: Source(values: rawSequence),
            pipeline: pipeline
        )
        
        skView.presentScene(scene)
        
        let editor = Editor(
            model: editorModel,
            releaseNextValue: { [weak self] in self?.releaseValue() },
            reset: { [weak self] in self?.scene.reset() }
        )
        
        let wrapper = UIHostingController(rootView: editor)
        wrapper.willMove(toParent: self)
        addChild(wrapper)
        view.addSubview(wrapper.view)
        wrapper.view.frame = CGRect(x: 0, y: simulationHeight, width: width, height: controlHeight)
        
        editor.model.$isSlowEnabled.sink { [weak self] isSlowEnabled in
            self?.scene.physicsWorld.speed = isSlowEnabled ? 0.5 : 1
        }.store(in: &cancellables)
    }
}
