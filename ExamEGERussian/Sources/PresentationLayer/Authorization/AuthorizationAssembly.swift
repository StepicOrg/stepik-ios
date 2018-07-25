//
//  AuthorizationAssemblyImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 16/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol AuthorizationAssembly {
    var greeting: AuthorizationGreetingAssembly { get }
    var signIn: AuthorizationSignInAssembly { get }
    var signUp: AuthorizationSignUpAssembly { get }
}

final class AuthorizationAssemblyImpl: BaseAssembly, AuthorizationAssembly {
    var greeting: AuthorizationGreetingAssembly {
        return AuthorizationGreetingAssemblyImpl(assemblyFactory: assemblyFactory, serviceFactory: serviceFactory)
    }

    var signIn: AuthorizationSignInAssembly {
        return AuthorizationSignInAssemblyImpl(assemblyFactory: assemblyFactory, serviceFactory: serviceFactory)
    }

    var signUp: AuthorizationSignUpAssembly {
        return AuthorizationSignUpAssemblyImpl(assemblyFactory: assemblyFactory, serviceFactory: serviceFactory)
    }
}
