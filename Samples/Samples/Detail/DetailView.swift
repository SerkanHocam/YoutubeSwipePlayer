//
//  DetailTable.swift
//  Test
//
//  Created by Serkan Kayaduman on 13.05.2023.
//

import UIKit

class DetailView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    init() {
        super.init(frame: .zero, style: .plain)
        self.setup()
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.setup()
    }
    
    private func setup() {
        self.dataSource = self
        self.delegate = self
        self.register(UINib(nibName: "TableCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.layoutMargins = .zero
        self.backgroundColor = .clear
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let parentFrame = self.superview?.bounds else { return }
        self.frame = parentFrame
    }
    
    //MARK: TableView datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCell(withIdentifier: "cell") as? TableCell
        
        cell?.updateViews(rowData: indexPath.row)
        return cell!
    }
    
    //MARK: TableView datasource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
