//
//  SocialNetworks.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation


enum SocialNetworks : Int {
    case VK = 0, Google, Facebook, Twitter
    
    var object : SocialNetwork {
        switch self {
        case VK: 
            return SocialNetwork(image: UIImage(named: "vk")!, 
                registerURL: NSURL(string: "https://stepic.org/accounts/google/login?next=%2Foauth2%2Fauthorize%2F%3Fclient_id%3D\(ClientIDs.socialClientId)%26response_type%3Dcode")!)
        case Google: 
            return SocialNetwork(image: UIImage(named: "google")!, 
                registerURL: NSURL(string: "https://stepic.org/accounts/google/login?next=%2Foauth2%2Fauthorize%2F%3Fclient_id%3D\(ClientIDs.socialClientId)%26response_type%3Dcode")!)
        case Facebook:
            return SocialNetwork(image: UIImage(named: "facebook")!, 
                registerURL: NSURL(string: "https://stepic.org/accounts/facebook/login?next=%2Foauth2%2Fauthorize%2F%3Fclient_id%3D\(ClientIDs.socialClientId)%26response_type%3Dcode")!)
        case Twitter:
            return SocialNetwork(image: UIImage(named: "twitter")!, 
                registerURL: NSURL(string: "https://stepic.org/accounts/twitter/login?next=%2Foauth2%2Fauthorize%2F%3Fclient_id%3D\(ClientIDs.socialClientId)%26response_type%3Dcode")!)
        }
    }
    
    var all: [SocialNetwork] {
        var res : [SocialNetwork] = []
        for i in 0...3 {
            res += [SocialNetworks(rawValue: i)!.object]
        }
        return res
    }
}

struct SocialNetwork {
    var image : UIImage!
    var registerURL : NSURL!
    
    init(image: UIImage, registerURL: NSURL) {
        self.image = image
        self.registerURL = registerURL
    }
}