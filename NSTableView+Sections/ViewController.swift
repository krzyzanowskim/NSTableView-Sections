//
//  ViewController.swift
//  NSTableView+Sections
//
//  Created by Marcin Krzyzanowski on 29/05/15.
//  Copyright (c) 2015 Marcin Krzyzanowski. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate {
    
    enum Section: Int {
        case People = 0
        case Group
        case Total
    }
    
    @IBOutlet var tableView: NSTableView!
    private var people:[String]?
    private var groups:[String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        people = ["Frakn","Monica","Natalie","Alice"]
        groups = ["Engineers","Teachers","Bookkeepers"]

        tableView.reloadData()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //MARK: - NSTableViewDelegate

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellView = tableView.makeViewWithIdentifier("CellView", owner: self) as! NSTableCellView
        let (section, sectionRow) = self.tableView(tableView, sectionForRow: row)
        switch (section) {
        case Section.People.rawValue:
            cellView.textField?.stringValue = people![sectionRow]
            break
        case Section.Group.rawValue:
            cellView.textField?.stringValue = groups![sectionRow]
            break
        default:
            break
        }
        
        return cellView
    }
}

//MARK: - NSTableViewSectionDataSource

extension ViewController: NSTableViewSectionDataSource {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        var total = 0
        for section in 0..<self.numberOfSectionsInTableView(tableView) {
            total += self.tableView(tableView, numberOfRowsInSection: section)
        }
        return total
    }
    
    func numberOfSectionsInTableView(tableView: NSTableView) -> Int {
        return Section.Total.rawValue
    }
    
    func tableView(tableView: NSTableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case Section.People.rawValue:
            return people?.count ?? 0
        case Section.Group.rawValue:
            return groups?.count ?? 0
        default:
            return 0
        }
    }

    func tableView(tableView: NSTableView, sectionForRow row: Int) -> (section: Int, row: Int) {
        let numberOfSections = self.numberOfSectionsInTableView(tableView)
        var counts = [Int](count: numberOfSections, repeatedValue: 0)
        
        for section in 0..<numberOfSections {
            counts[section] = self.tableView(tableView, numberOfRowsInSection: section)
        }
        
        let result = self.sectionForRow(row, counts: counts)
        return (section: result.section ?? 0, row: result.row ?? 0)
    }
    
    private func sectionForRow(row: Int, counts: [Int]) -> (section: Int?, row: Int?) {
        let total = reduce(counts, 0, +)
        
        var c = counts[0]
        for section in 0..<counts.count {
            if (section > 0) {
                c = c + counts[section]
            }
            if (row >= c - counts[section]) && row < c {
                return (section: section, row: row - (c - counts[section]))
            }
        }
        
        return (section: nil, row: nil)
    }
}