//
//  AuthentificationManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AuthentificationManager : NSObject {
    static var sharedManager = AuthentificationManager()
    
    private override init() {}
    
    
    func logInWithUsername(username : String, password : String, success : (token: StepicToken) -> Void, failure : (error : ErrorType) -> Void) {
        
        // Specifying the Headers we need
        let headers = [
            "Content-Type" : "application/x-www-form-urlencoded",
            "Authorization" : "Basic MXIxNVJneXhQdmI5MUtTU0RHd0RabEZXekVYbGVnRDl1ejUyTU40TzpwbEtyc0NFUmhRSkc5ajgzTHZYMmtHWk9HajFGNEdJenZnYXpyejFXMEppOG5ReHZuZHJiaUlwbXgxdE11RDFjaWlOMzJScDNmYjRjZTVKRnBmTDNacTBTM0xxREFuSGphREI2d0xUdG53QjI1VmxuZ1NPNThjREJMVnFrN2RHQQ=="
        ]
        
        let params = [
            "grant_type" : "password",
            "password" : password,
            "username" : username
        ]
        
        
        Alamofire.request(.POST, "https://stepic.org/oauth2/token/", parameters: params, headers: headers).responseSwiftyJSON({
            (_,_, json, error) in
            
            if let e = error {
                failure(error: e)
                return
            }
//            print(json)
//            print("no error")
            let token : StepicToken = StepicToken(json: json)
            print(token.accessToken)
            success(token: token)
        })
    }
    
    func refreshTokenWith(refresh_token : String, success : (token: StepicToken) -> Void, failure : (error : ErrorType) -> Void) {
        
        let headers = [
            "Content-Type" : "application/x-www-form-urlencoded",
            "Authorization" : "Basic MXIxNVJneXhQdmI5MUtTU0RHd0RabEZXekVYbGVnRDl1ejUyTU40TzpwbEtyc0NFUmhRSkc5ajgzTHZYMmtHWk9HajFGNEdJenZnYXpyejFXMEppOG5ReHZuZHJiaUlwbXgxdE11RDFjaWlOMzJScDNmYjRjZTVKRnBmTDNacTBTM0xxREFuSGphREI2d0xUdG53QjI1VmxuZ1NPNThjREJMVnFrN2RHQQ=="
        ]
        
        let params = [
            "grant_type" : "refresh_token",
            "refresh_token" : refresh_token]
        
        Alamofire.request(.POST, "https://stepic.org/oauth2/token/", parameters: params, headers: headers).responseSwiftyJSON({
            (_,_, json, error) in
            
            if let e = error {
                failure(error: e)
                return
            }
//            print(json)
//            print("no error")
            let token : StepicToken = StepicToken(json: json)
            print(token.accessToken)
            success(token: token)
        })
        
    }
    
    
    func registerWithFirstName(firstName: String, secondName: String, email: String, password: String) {
        let headers = [
            "Content-Type" : "application/x-www-form-urlencoded",
            "Authorization" : "Basic MXIxNVJneXhQdmI5MUtTU0RHd0RabEZXekVYbGVnRDl1ejUyTU40TzpwbEtyc0NFUmhRSkc5ajgzTHZYMmtHWk9HajFGNEdJenZnYXpyejFXMEppOG5ReHZuZHJiaUlwbXgxdE11RDFjaWlOMzJScDNmYjRjZTVKRnBmTDNacTBTM0xxREFuSGphREI2d0xUdG53QjI1VmxuZ1NPNThjREJMVnFrN2RHQQ=="
        ]
        
        let params = [
            "first_name" : firstName,
            "second_name" : secondName,
            "email" : email,
            "password" : password
        ]
        
        Alamofire.request(.POST, "https://stepic.org/api/users", parameters: params,  headers: headers).responseSwiftyJSON({
            (_, _, json, error) in
            
            if let _ = error {
                return
            }
            
            print(json)
            
        })
    }
    
}
