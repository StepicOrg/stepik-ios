//
//  DiscussionAlertConstructor.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class DiscussionAlertConstructor {
    static func getCommentAlert(_ comment: Comment, replyBlock: @escaping ((Void)->Void), likeBlock: @escaping ((Void)->Void), abuseBlock: @escaping ((Void)->Void), openURLBlock: @escaping ((URL)->Void)) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let links = HTMLParsingUtil.getAllLinksWithText(comment.text)
        
        for link in links {
            alert.addAction(UIAlertAction(title: link.text, style: .default, handler: 
                {
                    action in
                    if let url = URL(string: link.link.addingPercentEscapes(using: String.Encoding.utf8)!) {
                        openURLBlock(url)
                    }
                })
            )
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Reply", comment: ""), style: .default, handler: 
            {
                action in
                replyBlock()
        })
        )
        
        if comment.userId != AuthInfo.shared.userId {
        
            let likeTitle: String = (comment.vote.value == VoteValue.Epic) ? NSLocalizedString("Unlike", comment: "") : NSLocalizedString("Like", comment: "")
            
            alert.addAction(UIAlertAction(title: likeTitle, style: .default, handler: 
                {
                    action in
                    likeBlock()
            })
            )
            
            let abuseTitle: String = (comment.vote.value == VoteValue.Abuse) ? NSLocalizedString("Unabuse", comment: "") : NSLocalizedString("Abuse", comment: "")
            
            alert.addAction(UIAlertAction(title: abuseTitle, style: .destructive, handler: 
                {
                    action in
                    abuseBlock()
                })
            )
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        return alert
    }
}
