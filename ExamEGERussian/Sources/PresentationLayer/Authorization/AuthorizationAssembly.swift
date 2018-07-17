//
//  AuthorizationAssemblyImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 16/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol AuthorizationAssembly {
    func greeting() -> AuthorizationGreetingAssembly
    func signIn() -> AuthorizationSignInAssembly
    //func signUp() -> AuthorizationSignUpAssembly
}

final class AuthorizationAssemblyImpl: BaseAssembly, AuthorizationAssembly {
    func greeting() -> AuthorizationGreetingAssembly {
        return AuthorizationGreetingAssemblyImpl(assemblyFactory: assemblyFactory, serviceFactory: serviceFactory)
    }

    func signIn() -> AuthorizationSignInAssembly {
        return AuthorizationSignInAssemblyImpl(assemblyFactory: assemblyFactory, serviceFactory: serviceFactory)
    }
}
