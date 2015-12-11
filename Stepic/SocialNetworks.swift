//
//  SocialNetworks.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation


enum SocialNetworks : Int {
    case VK = 0, Google, Facebook, Twitter, GitHub, ITMailRu
    
    var object : SocialNetwork {
        switch self {
        case VK: 
            return SocialNetwork(image: UIImage(named: "vk_filled")!, 
                registerURL: NSURL(string: "https://stepic.org/accounts/vk/login?next=%2Foauth2%2Fauthorize%2F%3Fclient_id%3D\(StepicApplicationsInfo.social.clientId)%26response_type%3Dcode")!)
        case Google: 
            return SocialNetwork(image: UIImage(named: "google_filled")!, 
                registerURL: NSURL(string: "https://stepic.org/accounts/google/login?next=%2Foauth2%2Fauthorize%2F%3Fclient_id%3D\(StepicApplicationsInfo.social.clientId)%26response_type%3Dcode")!)
        case Facebook:
            return SocialNetwork(image: UIImage(named: "facebook_filled")!, 
                registerURL: NSURL(string: "https://stepic.org/accounts/facebook/login?next=%2Foauth2%2Fauthorize%2F%3Fclient_id%3D\(StepicApplicationsInfo.social.clientId)%26response_type%3Dcode")!)
        case Twitter:
            return SocialNetwork(image: UIImage(named: "twitter_filled")!, 
                registerURL: NSURL(string: "https://stepic.org/accounts/twitter/login?next=%2Foauth2%2Fauthorize%2F%3Fclient_id%3D\(StepicApplicationsInfo.social.clientId)%26response_type%3Dcode")!)
        case GitHub:
            return SocialNetwork(image: UIImage(named: "github")!, 
                registerURL: NSURL(string: "https://stepic.org/accounts/github/login?next=%2Foauth2%2Fauthorize%2F%3Fclient_id%3D\(StepicApplicationsInfo.social.clientId)%26response_type%3Dcode")!)
        case ITMailRu:
            return SocialNetwork(image: UIImage(named: "itmail")!, 
                registerURL: NSURL(string: "https://stepic.org/accounts/itmailru/login?next=%2Foauth2%2Fauthorize%2F%3Fclient_id%3D\(StepicApplicationsInfo.social.clientId)%26response_type%3Dcode")!)
        }
    }
    
    static var all: [SocialNetwork] {
        var res : [SocialNetwork] = []
        for i in 0..<6 {
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