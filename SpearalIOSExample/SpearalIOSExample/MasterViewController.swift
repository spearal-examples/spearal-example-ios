//
//  MasterViewController.swift
//  SpearalIOSExample
//
//  Created by Franck Wolff on 10/16/14.
//

import UIKit
import SpearalIOS

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    var persons = NSMutableArray()

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.persons = NSMutableArray()
        self.tableView.reloadData()
        
        let personService = AppDelegate.instance().personService
        personService.listPersons({ (paginatedListWrapper, error) -> Void in
            if error != nil {
                println("List persons error: \(error)")
            }
            else {
                var indexPaths = [NSIndexPath]()
                
                for person in paginatedListWrapper.list! {
                    self.persons.addObject(person)
                    indexPaths.append(NSIndexPath(forRow: indexPaths.count, inSection: 0))
                }
                
                self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func insertNewObject(sender: AnyObject) {
        self.performSegueWithIdentifier("showDetail", sender: sender)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let person = persons[indexPath.row] as Person
                let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
                controller.person = person
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
            else {
                let person = Person()
                person.id = nil
                let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
                controller.person = person
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func setEditing(editing: Bool, animated: Bool) {
        self.navigationItem.rightBarButtonItem?.enabled = !editing
        super.setEditing(editing, animated: animated)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        let person = persons[indexPath.row] as Person
        cell.textLabel.text = person.name ?? ""
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let person = persons[indexPath.row] as Person
            
            let personService = AppDelegate.instance().personService
            personService.deletePerson(person.id!.integerValue, completionHandler: { (error) -> Void in
                if error != nil {
                    println("Delete person error: \(error)")
                }
                else {
                    self.persons.removeObjectAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
            })
        }
    }
}

