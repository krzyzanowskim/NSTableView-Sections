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
            case .Group:
                return "GROUP"
            default:
                assertionFailure("Invalid section name")
                break
            }
            return ""
        }
    }
    
    @IBOutlet var tableView: NSTableView!
    private let people:[String] = ["Frank","Monica","Natalie","Alice"]
    private let groups:[String] = ["Engineers","Teachers","Bookkeepers"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }

    //MARK: - NSTableViewDelegate

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CellView"), owner: self) as! NSTableCellView
        
        if let dataSource = tableView.dataSource as? NSTableViewSectionDataSource {
            let (section, sectionRow) = dataSource.tableView(tableView: tableView, sectionForRow: row)

            if let headerView = self.tableView(tableView: tableView, viewForHeaderInSection: section) as? NSTableCellView, sectionRow == 0 {
                if let value = tableView.dataSource?.tableView!(tableView, objectValueFor: tableColumn, row: row) as? String {
                    headerView.textField?.stringValue = value
                }
                return headerView
            }
        }

        if let value = tableView.dataSource?.tableView!(tableView, objectValueFor: tableColumn, row: row) as? String {
            cellView.textField?.stringValue = value
        }
        return cellView
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if let dataSource = tableView.dataSource as? NSTableViewSectionDataSource {
            let (_, sectionRow) = dataSource.tableView(tableView: tableView, sectionForRow: row)

            if sectionRow == 0 {
                return false
            }
            
            return true
        }
        return false
    }
}

//MARK: - NSTableViewSectionDelegate

protocol NSTableViewSectionDelegate: NSTableViewDelegate {
    func tableView(tableView: NSTableView, viewForHeaderInSection section: Int) -> NSView?
}

extension ViewController: NSTableViewSectionDelegate {
    func tableView(tableView: NSTableView, viewForHeaderInSection section: Int) -> NSView? {
        switch (section) {
        case Section.People.rawValue:
            let sectionView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SectionView"), owner: self) as! NSTableCellView
            return sectionView
        case Section.Group.rawValue:
            let sectionView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SectionView"), owner: self) as! NSTableCellView
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
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if let dataSource = tableView.dataSource as? NSTableViewSectionDataSource {
            var (section, sectionRow) = dataSource.tableView(tableView: tableView, sectionForRow: row)
            
            if self.tableView(tableView: tableView, viewForHeaderInSection: section) != nil {
                if sectionRow == 0 {
                    return Section(rawValue: section)?.name as AnyObject?
                } else {
                    sectionRow -= 1
                }
            }
            
            switch (section) {
            case Section.People.rawValue:
                return people[sectionRow] as AnyObject
            case Section.Group.rawValue:
                return groups[sectionRow] as AnyObject
            default:
                return 0 as AnyObject
            }
        }
        return nil
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        var total = 0
        
        if let dataSource = tableView.dataSource as? NSTableViewSectionDataSource {
            for section in 0..<dataSource.numberOfSectionsInTableView(tableView: tableView) {
                total += dataSource.tableView(tableView: tableView, numberOfRowsInSection: section)
            }
        }
        
        return total
    }
    
    func numberOfSectionsInTableView(tableView: NSTableView) -> Int {
        return Section.Total.rawValue // 2
    }
    
    func tableView(tableView: NSTableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        
        if self.tableView(tableView: tableView, viewForHeaderInSection: section) != nil {
            count += 1
        }
        
        switch (section) {
        case Section.People.rawValue:
            count += people.count
        case Section.Group.rawValue:
            count += groups.count
        default:
            return 0
        }
        
        return count
    }

    func tableView(tableView: NSTableView, sectionForRow row: Int) -> (section: Int, row: Int) {
        if let dataSource = tableView.dataSource as? NSTableViewSectionDataSource {
            let numberOfSections = dataSource.numberOfSectionsInTableView(tableView: tableView)
            var counts = [Int](repeating: 0, count: numberOfSections)
            
            for section in 0..<numberOfSections {
                counts[section] = dataSource.tableView(tableView: tableView, numberOfRowsInSection: section)
            }
            
            let result = self.sectionForRow(row: row, counts: counts)
            return (section: result.section ?? 0, row: result.row ?? 0)
        }
        
        assertionFailure("Invalid datasource")
        return (section: 0, row: 0)
    }
    
    private func sectionForRow(row: Int, counts: [Int]) -> (section: Int?, row: Int?) {
//        let total = counts.reduce(0, +)

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
