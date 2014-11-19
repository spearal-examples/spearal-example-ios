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
    
    var person:Person?

    @IBAction func saveBtnClick(sender: UIBarButtonItem) {
        view.endEditing(true)
        
        let person = personFromUI()
        // let person = personDiffFromUI()

        let personService = AppDelegate.instance().personService

        personService.savePerson(person, completionHandler: { (person, error) -> Void in
            if person != nil {
                self.person = person
                self.configureView()
            }
            else {
                println("Save person error: \(error)")
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
                if person != nil {
                    self.person = person
                    self.configureView()
                }
                else {
                    println("Get person error: \(error)")
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
            self.imageUrlImg.image = nil

            if let imageUrl = person.imageUrl {
                loadImageData(imageUrl)
            }
        }
    }
    
    private func loadImageData(imageUrl:String) {
        let url = NSURL(string: imageUrl)
        if url == nil {
            println("Bad image URL error: \(imageUrl)")
        }
        else {
            let request:NSURLRequest = NSURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 5.0)
            
            NSURLConnection.sendAsynchronousRequest(
                request,
                queue: NSOperationQueue.mainQueue(),
                completionHandler: {(response, data, err) -> Void in
                    var error:NSError? = err
                    
                    if error == nil {
                        if (response as NSHTTPURLResponse).statusCode != 200 {
                            error = NSError(domain: "LoadImage", code: 1, userInfo: [
                                NSLocalizedDescriptionKey: "HTTP Status Code: \((response as NSHTTPURLResponse).statusCode)"
                            ])
                        }
                        else if data != nil && data.length > 0 {
                            if let image = UIImage(data: data) {
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.imageUrlImg.image = image
                                }
                            }
                            else {
                                error = NSError(domain: "LoadImage", code: 2, userInfo: [
                                    NSLocalizedDescriptionKey: "Unsupported image data: \(data)"
                                ])
                            }
                        }
                        else {
                            error = NSError(domain: "LoadImage", code: 3, userInfo: [
                                NSLocalizedDescriptionKey: "Empty image data: \(data)"
                            ])
                        }
                    }
                    
                    if error != nil {
                        println("Load image error (\(imageUrl)): \(error)")
                    }
                }
            )
        }
    }
}

