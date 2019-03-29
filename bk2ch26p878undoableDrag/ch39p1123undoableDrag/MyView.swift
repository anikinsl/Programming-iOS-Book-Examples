

import UIKit

class ViewController : UIViewController {
    
}

class MyView : UIView {
    
    let undoer = UndoManager()
    override var undoManager : UndoManager? {
        return self.undoer
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let p = UIPanGestureRecognizer(target: self, action: #selector(dragging))
        self.addGestureRecognizer(p)
        let l = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        self.addGestureRecognizer(l)
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    @objc func setCenterUndoably (_ newCenter:Any) {
        self.undoer.registerUndo(withTarget: self,
            selector: #selector(setCenterUndoably),
            object: self.center)
        self.undoer.setActionName("Move")
        if self.undoer.isUndoing || self.undoer.isRedoing {
            UIView.animate(withDuration:0.4, delay: 0.1, animations: {
                self.center = newCenter as! CGPoint
            })
        } else { // just do it
            self.center = newCenter as! CGPoint
        }
    }
    
    @objc func dragging (_ p : UIPanGestureRecognizer) {
        switch p.state {
        case .began:
            self.undoer.beginUndoGrouping()
            fallthrough
        case .changed:
            let delta = p.translation(in:self.superview!)
            var c = self.center
            c.x += delta.x; c.y += delta.y
            // self.center = c
            self.setCenterUndoably(c)
            p.setTranslation(.zero, in: self.superview!)
        case .ended, .cancelled:
            self.undoer.endUndoGrouping()
            self.becomeFirstResponder()
        default:break
        }
    }
    
    // ===== press-and-hold, menu

    @objc func longPress (_ g : UIGestureRecognizer) {
        if g.state == .began {
            let m = UIMenuController.shared
            m.setTargetRect(self.bounds, in: self)
            let mi1 = UIMenuItem(title: self.undoer.undoMenuItemTitle, action: #selector(undo))
            let mi2 = UIMenuItem(title: self.undoer.redoMenuItemTitle, action: #selector(redo))
            m.menuItems = [mi1, mi2]
            m.setMenuVisible(true, animated:true)
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(undo) {
            return self.undoer.canUndo
        }
        if action == #selector(redo) {
            return self.undoer.canRedo
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    @objc func undo(_: Any?) {
        self.undoer.undo()
    }
    
    @objc func redo(_: Any?) {
        self.undoer.redo()
    }
}
