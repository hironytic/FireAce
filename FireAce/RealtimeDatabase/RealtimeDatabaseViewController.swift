//
// RealtimeDatabaseViewController.swift
// FireAce
//
// Copyright (c) 2016 Hironori Ichimiya <hiron@hironytic.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit
import FirebaseDatabase

struct TodoItem {
    let itemId: String
    let content: String
    let completed: Bool
    let priority: Int
    
    init?(snapshot: FIRDataSnapshot) {
        self.itemId = snapshot.key
        guard let value = snapshot.value as? [String: AnyObject] else { return nil }
        self.content = value["content"] as? String ?? ""
        self.completed = value["completed"] as? Bool ?? false
        self.priority = value["priority"] as? Int ?? 3
    }
}

class RealtimeDatabaseViewController: UITableViewController {
    let todosRef = FIRDatabase.database().reference().child("todos")
    var todosQuery: FIRDatabaseQuery
    var items: [TodoItem] = []
    var childAddedHandle: FIRDatabaseHandle = 0
    var childRemovedHandle: FIRDatabaseHandle = 0
    var childChangedHandle: FIRDatabaseHandle = 0
    var childMovedHandle: FIRDatabaseHandle = 0
    
    required init?(coder decoder: NSCoder) {
        todosQuery = todosRef.queryOrderedByChild("priority")
        super.init(coder: decoder)
    }
    
    deinit {
        todosQuery.removeObserverWithHandle(childAddedHandle)
        todosQuery.removeObserverWithHandle(childRemovedHandle)
        todosQuery.removeObserverWithHandle(childChangedHandle)
        todosQuery.removeObserverWithHandle(childMovedHandle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        childAddedHandle = todosQuery.observeEventType(.ChildAdded, andPreviousSiblingKeyWithBlock: { [unowned self] (snapshot, prevKey) in
            if let item = TodoItem(snapshot: snapshot) {
                print("Added: \(item.itemId) => \(item.content)")
                
                let prevIndex = prevKey.flatMap({ prevKey in self.items.indexOf({ $0.itemId == prevKey }) }) ?? -1
                self.items.insert(item, atIndex: prevIndex + 1)
                self.tableView.reloadData()
            }
        })
        
        childRemovedHandle = todosQuery.observeEventType(.ChildRemoved, withBlock: { [unowned self] snapshot in
            let itemId = snapshot.key
            if let index = self.items.indexOf({ $0.itemId == itemId }) {
                self.items.removeAtIndex(index)
                self.tableView.reloadData()
            }
        })
        
        childChangedHandle = todosQuery.observeEventType(.ChildChanged, withBlock: { [unowned self] snapshot in
            let itemId = snapshot.key
            if let index = self.items.indexOf({ $0.itemId == itemId }) {
                if let newItem = TodoItem(snapshot: snapshot) {
                    self.items[index] = newItem
                    self.tableView.reloadData()
                }
            }
        })
        
        childMovedHandle = todosQuery.observeEventType(.ChildMoved, andPreviousSiblingKeyWithBlock: { [unowned self] (snapshot, prevKey) in
            print("Move: snapshot:\(snapshot.key), prevKey:\(prevKey)")
            
            guard let oldIndex = self.items.indexOf({ $0.itemId == snapshot.key }) else { return }
            let newIndex = (prevKey.flatMap({ prevKey in self.items.indexOf({ $0.itemId == prevKey }) }) ?? -1) + 1
            
            let item = self.items.removeAtIndex(oldIndex)
            if (oldIndex < newIndex) {
                self.items.insert(item, atIndex: newIndex - 1)
            } else {
                self.items.insert(item, atIndex: newIndex)
            }
            self.tableView.reloadData()
        })
    }
    
    @IBAction func menuButtonTapped(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "Add New ToDo", style: .Default, handler: { [weak self] action in
            self?.addNewToDo()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { [weak self] action in
            self?.dismissViewControllerAnimated(true, completion: nil)
        }))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func addNewToDo() {
        let newItem = todosRef.childByAutoId()
        newItem.updateChildValues([
            "content": "New ToDo",
            "completed": false,
            "priority": 3,
        ])
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = (item.completed ? "\u{2713} " : "") + "[\(item.priority)]" + item.content
        cell.accessoryType = .DisclosureIndicator
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let indexPath = tableView.indexPathForSelectedRow {
            let itemId = items[indexPath.row].itemId
            let editTodoViewController = segue.destinationViewController as! EditTodoViewController
            editTodoViewController.itemId = itemId
        }
    }

}

class EditTodoViewController : UITableViewController {
    @IBOutlet weak var contentField: UITextField!
    @IBOutlet weak var completeSwitch: UISwitch!
    @IBOutlet weak var prioritySegmented: UISegmentedControl!
    
    var itemId: String!
    var contentEditing: Bool = false
    
    var todoRef: FIRDatabaseReference!
    var valueHandle: FIRDatabaseHandle = 0
    
    deinit {
        todoRef.removeObserverWithHandle(valueHandle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contentField.enabled = false
        completeSwitch.enabled = false
        prioritySegmented.enabled = false

        todoRef = FIRDatabase.database().reference().child("todos/\(itemId)")
        valueHandle = todoRef.observeEventType(.Value, withBlock: { [unowned self] snapshot in
            if let item = TodoItem(snapshot: snapshot) {
                let content = item.content ?? ""
                let completed = item.completed ?? false
                
                if !self.contentEditing {
                    self.contentField.text = content
                }
                self.contentField.enabled = true
                
                self.completeSwitch.on = completed
                self.completeSwitch.enabled = true
                
                self.prioritySegmented.selectedSegmentIndex = item.priority - 1
                self.prioritySegmented.enabled = true
            } else {
                // this data might have been removed
                self.navigationController?.popViewControllerAnimated(true)
            }
        })
    }
    
    @IBAction func contentFieldEditingBegun(sender: AnyObject) {
        contentEditing = true
    }
    
    @IBAction func contentFieldEditingEnded(sender: AnyObject) {
        let content = contentField.text ?? ""
        todoRef.child("content").setValue(content)

        contentEditing = false
    }
    
    @IBAction func completeSwitchValueChanged(sender: AnyObject) {
        let completed = completeSwitch.on
        todoRef.child("completed").setValue(completed)
    }
    
    @IBAction func priorityValueChanged(sender: AnyObject) {
        let priority = prioritySegmented.selectedSegmentIndex + 1
        todoRef.child("priority").setValue(priority)
    }
    
    @IBAction func deleteButtonTapped(sender: AnyObject) {
        let alertController = UIAlertController(title: "Are you sure to delete this item?", message: nil, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { [weak self] action in
            self?.todoRef.removeValue()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
}
