//
//  PopAnimator.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 05/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 4.0
    var presenting = true
    
    private weak var mRoot: (UIViewController & IPopover)?
    
    init(root: UIViewController & IPopover) {
        mRoot = root
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        if presenting {
            mRoot?.show(container: containerView, completion: {
                transitionContext.completeTransition(true)
            })
        } else {
            mRoot?.hide(completion: {
                transitionContext.completeTransition(true)
                self.mRoot?.view.removeFromSuperview()
            })
        }
    }
    
}
