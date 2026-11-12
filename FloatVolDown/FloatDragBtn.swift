import UIKit

class FloatDragBtn: UIButton {
    var startPoint: CGPoint = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBlue
        layer.cornerRadius = 30
        setTitle("🔉-", for: .normal)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        startPoint = touches.first!.location(in: self)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let loc = touches.first!.location(in: superview!)
        center = CGPoint(x: loc.x - startPoint.x, y: loc.y - startPoint.y)
    }
}