//
//  ToUserDetailAnimationController.swift
//  GitClient
//
//  Created by John Leonard on 1/21/15.
//  Copyright (c) 2015 John Leonard. All rights reserved.
//

import UIKit

class ToUserDetailAnimationController : NSObject, UIViewControllerAnimatedTransitioning {
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
    return 0.4 // 0.4 sec
  } // transitionDuration()
  
  // custom transition
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    
    // get references to both of the view controllers
    let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as SearchUsersViewController
    let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as UserDetailViewController
    
    let containerView = transitionContext.containerView()
    
    // find the selected cell and make a snapshot of it
    let selectedIndexPath = fromVC.collectionView.indexPathsForSelectedItems().first as NSIndexPath
    let cell = fromVC.collectionView.cellForItemAtIndexPath(selectedIndexPath) as UserCell
    let snapshotOfCell = cell.imageView.snapshotViewAfterScreenUpdates(false)
    cell.imageView.hidden = true
    snapshotOfCell.frame = containerView.convertRect(cell.imageView.frame, fromView: cell.imageView.superview)
    
    // mave toVC start on screen with alpha set to 0 (transparent)
    toVC.view.frame = transitionContext.finalFrameForViewController(toVC) // translate from collection view coordinates  to container view corrdinates
    toVC.view.alpha = 0 // transparent
    toVC.imageView.hidden = true // don't see the cell as it moves
    
    containerView.addSubview(toVC.view)
    containerView.addSubview(snapshotOfCell)
    
    // tell autoLayout to make pass
    toVC.view.setNeedsLayout()
    toVC.view.layoutIfNeeded()
    
    let duration = self.transitionDuration(transitionContext)
    
    UIView.animateWithDuration(duration, animations: { () -> Void in
      toVC.view.alpha = 1.0 // move to fully visible
      
      // move the sanpshot
      let frame = containerView.convertRect(toVC.imageView.frame, fromView: toVC.view)
      snapshotOfCell.frame = frame
      }) { (finished) -> Void in
        
        // cleanup
        toVC.imageView.hidden = false
        cell.imageView.hidden = false
        snapshotOfCell.removeFromSuperview()
        transitionContext.completeTransition(true)
    } // finished enclosure
  } // animateTransition()
} // ToUserDetailAnimationController
