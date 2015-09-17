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
    
    
    func logInWithUsername(username : String, password : String, success : (token: StepicToken) -> Void, failure : (error : NSError) -> Void) {
        
        var manager = Manager.sharedInstance
        // Specifying the Headers we need
        let headers = [
            "Content-Type" : "application/x-www-form-urlencoded",
            "Authorization" : "Basic MXIxNVJneXhQdmI5MUtTU0RHd0RabEZXekVYbGVnRDl1ejUyTU40TzpwbEtyc0NFUmhRSkc5ajgzTHZYMmtHWk9HajFGNEdJenZnYXpyejFXMEppOG5ReHZuZHJiaUlwbXgxdE11RDFjaWlOMzJScDNmYjRjZTVKRnBmTDNacTBTM0xxREFuSGphREI2d0xUdG53QjI1VmxuZ1NPNThjREJMVnFrN2RHQQ=="
        ]
        
        var params = [
            "grant_type" : "password",
            "password" : password,
            "username" : username
        ]
        
        
        Alamofire.request(.POST, "https://stepic.org/oauth2/token/", parameters: params, headers: headers).responseSwiftyJSON({
            (_,_, json, error) in
            
            if let e = error {
                println(e.localizedDescription)
                failure(error: e)
                return
            }
            println(json)
            println("no error")
            let token = StepicToken(json: json)
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
            
            if let e = error {
                println(e.localizedDescription)
                return
            }
            
            println(json)
            
        })
        
    }
    
    
}
