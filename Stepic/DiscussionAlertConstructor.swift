//
//  DiscussionAlertConstructor.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class DiscussionAlertConstructor {
    static func getCommentAlert(comment: Comment, replyBlock: (Void->Void), likeBlock: (Void->Void), abuseBlock: (Void->Void), openURLBlock: (NSURL->Void)) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let links = HTMLParsingUtil.getAllLinksWithText(comment.text)
        
        for link in links {
            alert.addAction(UIAlertAction(title: link.text, style: .Default, handler: 
                {
                    action in
                    if let url = NSURL(string: link.link.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!) {
                        openURLBlock(url)
                    }
                })
            )
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Reply", comment: ""), style: .Default, handler: 
            {
                action in
                replyBlock()
        })
        )
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Like", comment: ""), style: .Default, handler: 
            {
                action in
                likeBlock()
        })
        )
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Abuse", comment: ""), style: .Destructive, handler: 
            {
                action in
                abuseBlock()
            })
        )
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
        
        return alert
    }
}