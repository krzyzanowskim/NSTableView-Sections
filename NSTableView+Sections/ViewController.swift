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
        
        var name:String {
            switch (self) {
            case .People:
                return "PEOPLE"
            case Group:
                return "GROUP"
            default:
                assertionFailure("Invalid section name")
                break
            }
            return ""
        }
    }
    
    @IBOutlet var tableView: NSTableView!
    private let people:[String] = ["Frakn","Monica","Natalie","Alice"]
    private let groups:[String] = ["Engineers","Teachers","Bookkeepers"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }

    override var representedObject: AnyObject? {
        didSet {
        }
    }
    
    //MARK: - NSTableViewDelegate

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellView = tableView.makeViewWithIdentifier("CellView", owner: self) as! NSTableCellView
        if let value = tableView.dataSource()?.tableView?(tableView, objectValueForTableColumn: tableColumn, row: row) as? String {
            cellView.textField?.stringValue = value
        }
        return cellView
    }
}

//MARK: - NSTableViewSectionDelegate

protocol NSTableViewSectionDelegate: NSTableViewDelegate {
    func tableView(tableView: NSTableView, viewForHeaderInSection section: Int) -> NSTableCellView?
}

extension ViewController: NSTableViewSectionDelegate {
    func tableView(tableView: NSTableView, viewForHeaderInSection section: Int) -> NSTableCellView? {
        switch (section) {
        case Section.People.rawValue:
            let sectionView = tableView.makeViewWithIdentifier("SectionView", owner: self) as! NSTableCellView
            return sectionView
        case Section.Group.rawValue:
            let sectionView = tableView.makeViewWithIdentifier("SectionView", owner: self) as! NSTableCellView
            return sectionView
        default:
            break
        }
        return nil
    }
}

//MARK: - NSTableViewSectionDataSource

protocol NSTableViewSectionDataSource: NSTableViewDataSource {
    func numberOfSectionsInTableView(tableView: NSTableView) -> Int
    func tableView(tableView: NSTableView, numberOfRowsInSection section: Int) -> Int
    func tableView(tableView: NSTableView, sectionForRow row: Int) -> (section: Int, row: Int)
}

extension ViewController: NSTableViewSectionDataSource {
    
    // Optional
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if let dataSource = tableView.dataSource() as? NSTableViewSectionDataSource {
            let (section, sectionRow) = dataSource.tableView(tableView, sectionForRow: row)
                switch (section) {
                case Section.People.rawValue:
                    return people[sectionRow]
                case Section.Group.rawValue:
                    return groups[sectionRow]
                default:
                    return 0
                }
        }
        return nil
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        var total = 0
        
        if let dataSource = tableView.dataSource() as? NSTableViewSectionDataSource {
            for section in 0..<dataSource.numberOfSectionsInTableView(tableView) {
                total += dataSource.tableView(tableView, numberOfRowsInSection: section)
            }
        }
        
        return total
    }
    
    func numberOfSectionsInTableView(tableView: NSTableView) -> Int {
        return Section.Total.rawValue
    }
    
    func tableView(tableView: NSTableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case Section.People.rawValue:
            return people.count
        case Section.Group.rawValue:
            return groups.count
        default:
            return 0
        }
    }

    func tableView(tableView: NSTableView, sectionForRow row: Int) -> (section: Int, row: Int) {
        if let dataSource = tableView.dataSource() as? NSTableViewSectionDataSource {
            let numberOfSections = dataSource.numberOfSectionsInTableView(tableView)
            var counts = [Int](count: numberOfSections, repeatedValue: 0)
            
            for section in 0..<numberOfSections {
                counts[section] = dataSource.tableView(tableView, numberOfRowsInSection: section)
            }
            
            let result = self.sectionForRow(row, counts: counts)
            return (section: result.section ?? 0, row: result.row ?? 0)
        }
        
        assertionFailure("Invalid datasource")
        return (section: 0, row: 0)
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