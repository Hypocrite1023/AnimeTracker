//
//  RightSwipeDismissPresentationController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/30.
//

import UIKit

class RightSwipeDismissPresentationController: UIPresentationController {
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        print("111")
        if let containerView = containerView {
            print("222")
            let rightSiwpeToDismissGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(dismissPresentationController(_:)))
            rightSiwpeToDismissGesture.edges = .all // starting from left, left swipe to right
            containerView.addGestureRecognizer(rightSiwpeToDismissGesture)
            print("gesture add")
        }
    }
    
    @objc func dismissPresentationController(_ gesture: UIScreenEdgePanGestureRecognizer) {
        print("gesture start")
        let viewController = presentedViewController
        let translation = gesture.translation(in: gesture.view)
        print(translation.x, translation.y)
    }

}

extension RightSwipeDismissPresentationController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
