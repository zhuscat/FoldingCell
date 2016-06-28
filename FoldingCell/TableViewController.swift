//
//  TableViewController.swift
//  FoldingCell
//
//  Created by Leaf on 16/6/24.
//  Copyright © 2016年 zhuscat. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var cellHeights = [CGFloat]()
    
    let cellCount = 6
    
    let rowHeightClose: CGFloat = 196.0
    let rowHeightOpen: CGFloat = 566.0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        for _ in 0..<cellCount {
            cellHeights.append(rowHeightClose)
        }
        
        tableView.backgroundColor = UIColor(red: 204.0 / 255.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 1)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cellCount
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("identifier")
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        cell?.contentView.backgroundColor = UIColor(red: 204.0 / 255.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 1)
        cell?.backgroundColor = UIColor.grayColor()
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(#function)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FoldingCell
        if cellHeights[indexPath.row] == rowHeightClose {
            cellHeights[indexPath.row] = rowHeightOpen
            (tableView.cellForRowAtIndexPath(indexPath) as! FoldingCell).startOpenAnimation()
            UIView.animateWithDuration(cell.totalDuration) {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        } else {
            cellHeights[indexPath.row] = rowHeightClose
            (tableView.cellForRowAtIndexPath(indexPath) as! FoldingCell).startCloseAnimation()
            UIView.animateWithDuration(cell.totalDuration * 2) {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
