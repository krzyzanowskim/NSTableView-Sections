//
//  NSTableViewSectionDataSource.swift
//  NSTableView+Sections
//
//  Created by Marcin Krzyzanowski on 29/05/15.
//  Copyright (c) 2015 Marcin Krzyzanowski. All rights reserved.
//

import Cocoa

protocol NSTableViewSectionDataSource: NSTableViewDataSource {
    func numberOfSectionsInTableView(tableView: NSTableView) -> Int
    func tableView(tableView: NSTableView, numberOfRowsInSection section: Int) -> Int
    func tableView(tableView: NSTableView, sectionForRow row: Int) -> (section: Int, row: Int)
}