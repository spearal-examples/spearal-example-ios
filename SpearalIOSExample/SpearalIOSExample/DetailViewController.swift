//
//  DetailViewController.swift
//  SpearalIOSExample
//
//  Created by Franck Wolff on 10/16/14.
//

import UIKit
import SpearalIOS

class DetailViewController: UIViewController {
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var descriptionText: UITextField!
    @IBOutlet weak var imageUrlText: UITextField!
    @IBOutlet weak var imageUrlImg: UIImageView!
    
    var person: Person?

    @IBAction func saveBtnClick(sender: UIBarButtonItem) {
        let person = personFromUI()
        // let person = personDiffFromUI()

        let personService = AppDelegate.instance().personService

        personService.savePerson(person, completionHandler: { (person, error) -> Void in
            if error != nil {
                println("Save person error: \(error)")
            }
            else {
                self.person = person
                self.configureView()
            }
        })
    }
    
    private func personFromUI() -> Person {
        let person = Person()
        
        person.id = self.person!.id
        person.name = self.nameText!.text
        person.description_ = self.descriptionText!.text
        person.imageUrl = self.imageUrlText!.text
        
        return person
    }
    
    private func personDiffFromUI() -> Person {
        let person = Person()
        
        person.id = self.person!.id
        
        if self.person!.name != self.nameText!.text {
            person.name = self.nameText!.text
        }
        if self.person!.description_ != self.descriptionText!.text {
            person.description_ = self.descriptionText!.text
        }
        if self.person!.imageUrl != self.imageUrlText!.text {
            person.imageUrl = self.imageUrlText!.text
        }
        
        return person
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.person!.id != nil {
            let personService = AppDelegate.instance().personService

            personService.getPerson(self.person!.id!.integerValue, completionHandler: { (person, error) -> Void in
                if error != nil {
                    println("Get person error: \(error)")
                }
                else {
                    self.person = person
                    self.configureView()
                }
            })
        }
        else {
            self.configureView()
        }
    }
    
    private func configureView() {
        
        if let person = self.person {
            
            self.nameText.text = person.name ?? ""
            self.descriptionText.text = person.description_ ?? ""
            self.imageUrlText.text = person.imageUrl ?? ""
            
            if let imageUrl = person.imageUrl {
                let url = NSURL(string: imageUrl)!
                let request:NSURLRequest = NSURLRequest(URL: url, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 5.0)
                
                NSURLConnection.sendAsynchronousRequest(
                    request,
                    queue: NSOperationQueue.mainQueue(),
                    completionHandler: {(response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
                        if data != nil && data.length > 0 {
                            let image = UIImage(data: data)
                            dispatch_async(dispatch_get_main_queue()) {
                                self.imageUrlImg.image = image
                            }
                        }
                        else {
                            println("[No image data] error: \(error), response: \(response)")
                        }
                    }
                )
            }
        }
    }
}

