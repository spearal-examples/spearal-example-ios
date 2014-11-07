//
//  Person.swift
//  SpearalIOSExample
//
//  Created by Franck Wolff on 10/17/14.
//

import Foundation
import SpearalIOS

@objc(PaginatedListWrapper)
public class PaginatedListWrapper: NSObject {
    
    public var currentPage:NSNumber?
    public var pageSize:NSNumber?
    public var totalResults:NSNumber?
    
    public var sortFields:String?
    public var sortDirections:String?
    public var list:[Person]?
}
