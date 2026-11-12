import UIKit
class FloatDragBtn: UIButton {
    var offset: CGPoint = .zero
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let t = touches.first else { return }
        offset = t.location(in: self)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let t = touches.first, let sup = superview else { return }
        let loc = t.location(in: sup)
        center = CGPoint(x: loc.x - offset.x, y: loc.y - offset.y)
    }
}