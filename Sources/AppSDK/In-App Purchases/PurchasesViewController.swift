//
//  PurchasesViewController.swift
//  SuperWindow
//
//  Created by Joe Manto on 9/26/21.
//

import Foundation
import StoreKit

#if os(macOS)
class PurchasesViewController : NSViewController, NSTableViewDataSource, NSTableViewDelegate, PurchasesTableCellDelegate, IAPManagerDelegate {

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var subTitleLabel: NSTextField!
    @IBOutlet weak var restoreSubTitle: NSTextField!
    @IBOutlet var seperator: NSView!
    @IBOutlet weak var restoreBtn: NSButton!
    
    let scrollView = NSScrollView()
    let tableView = NSTableView()
    var products: [SKProduct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.products = IAPManager.shared.products
        self.setUpTableView()
        self.setUpConstraints()
        
        titleLabel.stringValue = NSLocalizedString("Purchases", comment: "")
        restoreBtn.title = NSLocalizedString("Restore", comment: "")
        restoreSubTitle.stringValue = NSLocalizedString("Applies any SuperWindow In-app purchases linked to your Apple-ID", comment: "")
        subTitleLabel.stringValue = NSLocalizedString("Place to manage and restore purchases", comment: "")
        
        self.restoreBtn.target = self
        self.restoreBtn.action = #selector(self.didHitRestoreButton(_:))
        
        IAPManager.shared.delegate = self
    }
    
    func setUpTableView() {
        self.view.addSubview(scrollView)
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = NSColor.clear
        scrollView.drawsBackground = false

        tableView.frame = scrollView.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.headerView = nil
        tableView.usesAutomaticRowHeights = true
        
        tableView.backgroundColor = .clear
        //tableView.appearance = NSAppearance(named: NSAppearance.Name.vibrantLight)

        let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "col"))
        col.minWidth = 200
        tableView.addTableColumn(col)
        
        scrollView.documentView = tableView
        scrollView.hasHorizontalScroller = false
        scrollView.hasVerticalScroller = false
    }
    
    func setUpConstraints() {
        NSLayoutConstraint.activate([
            self.scrollView.topAnchor.constraint(equalTo: restoreSubTitle.bottomAnchor, constant: 50),
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.subTitleLabel.trailingAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        products.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard row < products.count else {
            return nil
        }
        
        let isPurchased = UserDefaults.standard.bool(forKey: self.products[row].productIdentifier)
        let model = PurchasesTableCellModel(product: self.products[row], isPurchased: isPurchased)
        let cell = PurchasesTableCell(model: model)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = NSTableRowView()
        rowView.isEmphasized = false
        rowView.selectionHighlightStyle = .none
        return rowView
    }
    
    func didHitPurchaseButton(_ sender: NSButton, model: PurchasesTableCellModel) {
        // Todo check if product is purchased NOT ui check
        IAPManager.shared.purchase(Product(name: "", id: model.product.productIdentifier))
    }
    
    @objc func didHitRestoreButton(_ sender: NSButton) {
        IAPManager.shared.restore()
    }
    
    func didReceiveMessage(_ message: IAPManagerMessage, errorMsg: String?) {
        
        var alertMessage: String?
        var alertTitle: String?
        
        switch message {
        case .processedAllRestorable:
            DispatchQueue.main.sync {
                self.tableView.reloadData()
            }
        case .restoredPurchases:
            DispatchQueue.main.sync {
                self.tableView.reloadData()
            }
        case .errorRestoringPurchases:
            alertTitle = NSLocalizedString("A problem occurred while restoring your purchases. Please retry", comment: "")
            alertMessage = errorMsg
        case .transactionFailed:
            alertTitle = NSLocalizedString("Transaction Failed. Please retry", comment: "")
            alertMessage = errorMsg
        case .cantMakePurchases:
            alertTitle = NSLocalizedString("Your account is not authorized to make purchases", comment: "")
            alertMessage = ""
        case .purchasedItem:
            DispatchQueue.main.sync {
                self.tableView.reloadData()
            }
        }
        
        if let alertTitle = alertTitle {
            if let alertMessage = alertMessage {
                DispatchQueue.main.sync {
                    AppSDKUtil.showStoreKitAlert(title: alertTitle, msg: alertMessage)
                }
                return
            }
            DispatchQueue.main.sync {
                AppSDKUtil.showStoreKitAlert(title: alertTitle, msg: "")
            }
        }
    }
}
#endif
