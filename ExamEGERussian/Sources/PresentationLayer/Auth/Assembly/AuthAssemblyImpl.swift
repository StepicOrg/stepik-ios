//
//  AuthorizationAssemblyImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 27/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class AuthAssemblyImpl: BaseAssembly, AuthAssembly {
    var greeting: AuthGreetingAssembly {
        return AuthGreetingAssemblyImpl(assemblyFactory: assemblyFactory, serviceFactory: serviceFactory)
    }

    var signIn: AuthSignInAssembly {
        return AuthSignInAssemblyImpl(assemblyFactory: assemblyFactory, serviceFactory: serviceFactory)
    }

    var signUp: AuthSignUpAssembly {
        return AuthSignUpAssemblyImpl(assemblyFactory: assemblyFactory, serviceFactory: serviceFactory)
    }
}
