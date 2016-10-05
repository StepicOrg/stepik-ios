//
//  SocialNetworks.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation


enum SocialNetworks : Int {
    case vk = 0, google, facebook, twitter, gitHub, itMailRu
    
    var object : SocialNetwork {
        switch self {
        case .vk: 
            return SocialNetwork(name: self.name, image: UIImage(named: "vk_filled")!, 
                registerURL: URL(string: "https://stepik.org/accounts/vk/login?next=%2Foauth2%2Fauthorize%2F%3Fclient_id%3D\(StepicApplicationsInfo.social!.clientId)%26response_type%3Dcode")!)
        case .google: 
            return SocialNetwork(name: self.name, image: UIImage(named: "google_filled")!, 
                registerURL: URL(string: "https://stepik.org/accounts/google/login?next=%2Foauth2%2Fauthorize%2F%3Fclient_id%3D\(StepicApplicationsInfo.social!.clientId)%26response_type%3Dcode")!)
        case .facebook:
            return SocialNetwork(name: self.name, image: UIImage(named: "facebook_filled")!, 
                registerURL: URL(string: "https://stepik.org/accounts/facebook/login?next=%2Foauth2%2Fauthorize%2F%3Fclient_id%3D\(StepicApplicationsInfo.social!.clientId)%26response_type%3Dcode")!)
        case .twitter:
            return SocialNetwork(name: self.name, image: UIImage(named: "twitter_filled")!, 
                registerURL: URL(string: "https://stepik.org/accounts/twitter/login?next=%2Foauth2%2Fauthorize%2F%3Fclient_id%3D\(StepicApplicationsInfo.social!.clientId)%26response_type%3Dcode")!)
        case .gitHub:
            return SocialNetwork(name: self.name, image: UIImage(named: "github")!, 
                registerURL: URL(string: "https://stepik.org/accounts/github/login?next=%2Foauth2%2Fauthorize%2F%3Fclient_id%3D\(StepicApplicationsInfo.social!.clientId)%26response_type%3Dcode")!)
        case .itMailRu:
            return SocialNetwork(name: self.name, image: UIImage(named: "itmail")!, 
                registerURL: URL(string: "https://stepik.org/accounts/itmailru/login?next=%2Foauth2%2Fauthorize%2F%3Fclient_id%3D\(StepicApplicationsInfo.social!.clientId)%26response_type%3Dcode")!)
        }
    }
    
    static var all: [SocialNetwork] {
        var res : [SocialNetwork] = []
        for i in 0..<6 {
            res += [SocialNetworks(rawValue: i)!.object]
        }
        return res
    }
    
    var name: String {
        switch self {
        case .vk: 
            return "VK"
        case .google: 
            return "Google"
        case .facebook:
            return "Facebook"
        case .twitter: 
            return "Twitter"
        case .gitHub:
            return "GitHub"
        case .itMailRu:
            return "ITMailRu"
        }
    }
}

struct SocialNetwork {
    var image : UIImage!
    var registerURL : URL!
    var name: String!
    init(name: String, image: UIImage, registerURL: URL) {
        self.name = name
        self.image = image
        self.registerURL = registerURL
    }
}
