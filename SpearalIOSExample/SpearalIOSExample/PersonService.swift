//
//  PersonsService.swift
//  SpearalIOSExample
//
//  Created by Franck Wolff on 11/4/14.
//

import Foundation
import SpearalIOS

class PersonService {
    
    private let personUrl = "https://examples-spearal.rhcloud.com/spring-angular/resources/persons"
    // private let personUrl = "https://examples-spearal.rhcloud.com/spring-angular-v2/resources/persons"
    
    private let session:NSURLSession
    private let factory:SpearalFactory
    
    init() {
        self.session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())
        
        self.factory = DefaultSpearalFactory()
        let aliasStrategy = BasicSpearalAliasStrategy(localToRemoteClassNames: [
            "Person": "org.spearal.samples.springangular.data.Person",
            "PaginatedListWrapper": "org.spearal.samples.springangular.pagination.PaginatedListWrapper"
            ])
        aliasStrategy.setPropertiesAlias("Person", localToRemoteProperties: [
            "description_" : "description"
            ])
        factory.context.configure(aliasStrategy)
    }
    
    func listPersons(completionHandler: ((PaginatedListWrapper!, NSError!) -> Void)) {
        let request = createRequest("\(personUrl)?pageSize=100", method: "GET")
        // request.addValue("org.spearal.samples.springangular.data.Person#name", forHTTPHeaderField: "Spearal-PropertyFilter")
        
        executeRequest(request, completionHandler: { (list:PaginatedListWrapper?, error:NSError?) -> Void in
            completionHandler(list, error)
        })
    }
    
    func getPerson(id:Int, completionHandler: ((Person!, NSError!) -> Void)) {
        let request = createRequest("\(personUrl)/\(id)", method: "GET")
        // request.addValue("org.spearal.samples.springangular.data.Person#id,name,description,imageUrl", forHTTPHeaderField: "Spearal-PropertyFilter")
        
        executeRequest(request, completionHandler: { (person:Person?, error:NSError?) -> Void in
            completionHandler(person, error)
        })
    }
    
    func savePerson(person:Person, completionHandler: ((Person!, NSError!) -> Void)) {
        let request = createRequest(personUrl, method: "POST")
        request.HTTPBody = encode(person)
        
        executeRequest(request, completionHandler: { (person:Person?, error:NSError?) -> Void in
            completionHandler(person, error)
        })
    }
    
    func deletePerson(id:Int, completionHandler: ((NSError!) -> Void)) {
        let request = createRequest("\(personUrl)/\(id)", method: "DELETE")
        
        executeRequest(request, completionHandler: { (any:Any?, error:NSError?) -> Void in
            completionHandler(error)
        })
    }
    
    func createRequest(url:String, method:String) -> NSMutableURLRequest {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = method
        request.addValue("application/spearal", forHTTPHeaderField: "Content-Type")
        request.addValue("application/spearal", forHTTPHeaderField: "Accept")
        return request
    }
    
    func executeRequest<T>(request:NSURLRequest, completionHandler:((T?, NSError?) -> Void)) {
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, err) -> Void in
            var error:NSError? = err
            var value:T? = nil
            
            if error == nil {
                if (response as NSHTTPURLResponse).statusCode != 200 {
                    error = NSError(domain: "Spearal", code: 1, userInfo: [
                        NSLocalizedDescriptionKey: "HTTP Status Code: \((response as NSHTTPURLResponse).statusCode)"
                    ])
                }
                else if data.length > 0 {
                    value = self.decode(data)
                }
            }

            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(value, error)
            }
        })
        
        task.resume()
    }
    
    func decode<T>(data:NSData) -> T? {
        let printer = SpearalDefaultPrinter(SpearalPrinterStringOutput())
        
        let decoder:SpearalDecoder = self.factory.newDecoder(SpearalNSDataInput(data: data), printer: printer)
        let any = decoder.readAny()
        
        println("RESPONSE (data length: \(data.length) bytes)")
        println((printer.output as SpearalPrinterStringOutput).value)
        println("--")
        
        return any as? T
    }
    
    func encode(any:Any) -> NSData {
        let printer = SpearalDefaultPrinter(SpearalPrinterStringOutput())
        
        let output = SpearalNSDataOutput()
        let encoder = factory.newEncoder(output, printer: printer)
        encoder.writeAny(any)
        
        println("REQUEST (data length: \(output.data.length) bytes)")
        println((printer.output as SpearalPrinterStringOutput).value)
        println("--")
        
        return output.data
    }
}