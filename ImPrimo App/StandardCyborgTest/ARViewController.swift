//
//  ARViewController.swift
//  StandardCyborgTest
//
//  Created by Ridvan Song on 2020-03-29.
//  Copyright © 2020 Ridvan Song. All rights reserved.
//

//
//  ARTestViewController.swift
//  Print.ology
//
//  Created by Trav Haran on 2020-01-26.
//  Copyright © 2020 Dollar  Luo. All rights reserved.
//

import UIKit
import ARKit
import Moya

class ARViewController: QLPreviewController, QLPreviewControllerDataSource{
    
    let testView = UIView()
    private var filename: String!
    
    init(filename: String) {
        self.filename = filename
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        
        setupView()
    }
    
    private func setupView() {
        
        self.view.addSubview(testView)
        testView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            testView.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor),
            testView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            testView.heightAnchor.constraint(equalToConstant: 100)
        ])

        let view = UIButton()
        testView.addSubview(view)
        view.frame = CGRect(x: 0, y: 0, width: 327, height: 53)

        view.backgroundColor = .blue
        view.setTitle("Print", for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = UIFont(name:"Avenir", size: 18)
        view.layer.cornerRadius = 25
        view.centerXAnchor.constraint(equalTo: testView.centerXAnchor).isActive = true

        

        view.translatesAutoresizingMaskIntoConstraints = false

        view.widthAnchor.constraint(equalToConstant: 327).isActive = true

        view.heightAnchor.constraint(equalToConstant: 53).isActive = true
        NSLayoutConstraint.activate([
            testView.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor),
            testView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            testView.heightAnchor.constraint(equalToConstant: 100)
        ])
        view.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

    }
    
    @objc func buttonTapped(){
        let file = String(filename)
        let networkProvider = MoyaProvider<PrintService>()
//        print(file)
//        networkProvider.request(.printFile(named: "\(file).stl")){ (response) in
//                    switch response {
//                    case .failure:
//                        let alert = UIAlertController(title: "FAILED",
//                                                      message: "FAILED TO RETRIEVE FILE",
//                                                      preferredStyle: .alert)
//                        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
//                        self.present(alert, animated: true, completion: nil)
//                    case .success:
//                        print("yay")
//                        
//                    
//                }
//        }
    }
    
    func buttonDone(){
        
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) ->
    QLPreviewItem {
            guard let path = Bundle.main.path(forResource: String(filename!), ofType: "usdz") else { fatalError("Couldn't find the supported input file.") }
            let url = URL(fileURLWithPath: path)
            return url as QLPreviewItem
    }
    
}
