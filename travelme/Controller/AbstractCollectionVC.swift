//
//  AbstractCollectionVC.swift
//  travelme
//
//  Created by DiepViCuong on 2/14/21.
//

import Foundation

class AbstractCollectionVC: AbstractViewController, HomePostCellDelegate{
    var posts = [Post]()
    func showEmptyStateViewIfNeeded(){}
    
    func didTapComment(post: Post) {
        debugPrint("didTapComment")
    }
    
    func didTapUser(user: User) {
        debugPrint("didTapUser")
    }
    
    func didTapOptions(post: Post) {
        debugPrint("didTapOptions")
    }
    
    func didLike(for cell: HomePostCollectionViewCell) {
        debugPrint("didLike")
    }
    
}
