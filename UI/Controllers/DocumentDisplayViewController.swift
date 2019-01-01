//
//  DocumentDisplayCiewControllerViewController.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 29/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit
import PDFKit

class DocumentDisplayViewController: UIViewController {

    private let LOGGER = Logger.getInstance()
    
    var documentUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let docUrl = documentUrl {
            
            pdfViewerOutlet.autoScales = true
            pdfViewerOutlet.document = PDFDocument(url: docUrl)
            LOGGER.debug(msg: "viewDidLoad, documentUrl=\(String(describing: documentUrl))")
        }
        else {
            LOGGER.debug(msg: "viewDidLoad, no documentUrl")
        }
    }
    @IBAction func closButton(_ sender: UIButton) {
        
        let saveReadingState: () -> Void = {
            // TODO: save reading state
            print("Document closed")
        }
        
        self.dismiss(animated: true, completion: saveReadingState)
    }
    
    @IBOutlet weak var pdfViewerOutlet: PDFView!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
