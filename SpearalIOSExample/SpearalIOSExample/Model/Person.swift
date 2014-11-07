//
//  Person.swift
//  SpearalIOSExample
//
//  Created by Franck Wolff on 10/17/14.
//

import Foundation
import SpearalIOS

@objc(Person)
public class Person: SpearalAutoPartialable {
    
    public dynamic var id:NSNumber?
    public dynamic var name:String?
    public dynamic var description_:String?
    public dynamic var imageUrl:String?
}
