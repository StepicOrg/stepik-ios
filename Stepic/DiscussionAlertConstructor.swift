//
//  DiscussionAlertConstructor.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

final class DiscussionAlertConstructor {
    static func getCommentAlert(
        _ comment: Comment,
        replyBlock: @escaping (() -> Void),
        likeBlock: @escaping (() -> Void),
        abuseBlock: @escaping (() -> Void),
        openURLBlock: @escaping ((URL) -> Void)
    ) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let links = HTMLParsingUtil.getAllLinksWithText(comment.text).compactMap { item -> (url: URL, text: String)? in
            if let decodedLink = item.link.removingPercentEncoding,
               let encodedLink = decodedLink.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: encodedLink) {
                return (url: url, text: item.text)
            } else {
                return nil
            }
        }

        for link in links {
            alert.addAction(UIAlertAction(title: link.text, style: .default, handler: { _ in
                openURLBlock(link.url)
            }))
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("Reply", comment: ""), style: .default, handler: { _ in
            replyBlock()
        }))

        if comment.userId != AuthInfo.shared.userId {
            let likeTitle: String = (comment.vote.value == VoteValue.epic)
                ? NSLocalizedString("Unlike", comment: "")
                : NSLocalizedString("Like", comment: "")
            alert.addAction(UIAlertAction(title: likeTitle, style: .default, handler: {
                _ in
                likeBlock()
            }))

            let abuseTitle: String = (comment.vote.value == VoteValue.abuse)
                ? NSLocalizedString("Unabuse", comment: "")
                : NSLocalizedString("Abuse", comment: "")
            alert.addAction(UIAlertAction(title: abuseTitle, style: .destructive, handler: {
                _ in
                abuseBlock()
            }))
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))

        return alert
    }
}
