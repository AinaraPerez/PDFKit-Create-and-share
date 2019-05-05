//
//  ViewController.swift
//  PDFCreateAndShare
//
//  Created by Ainara Perez on 2/5/19.
//  Copyright © 2019 Ainara Perez. All rights reserved.
//

import UIKit
import PDFKit

class ViewController: UIViewController, UIDocumentInteractionControllerDelegate {

    @IBOutlet weak var btCreatePDF: UIButton!
    @IBOutlet weak var btViewPDF: UIButton!
    @IBOutlet weak var btSharePDF: UIButton!
    
    var filePath: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btCreatePDF.layer.cornerRadius = 10
        btViewPDF.layer.cornerRadius = 10
        btSharePDF.layer.cornerRadius = 10
    }

    @IBAction func createPDF(_ sender: Any) {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        filePath = (documentsDirectory as NSString).appendingPathComponent("Test.pdf") as String
        
        let pdfTitle = "Swift PDF Test"
        let pdfSubject = "Your text here, press anywhere to go back"
        let pdfMetadata = [
            // The name of the application creating the PDF.
            kCGPDFContextCreator: "Your iOS App",
            // Creator of the PDF
            kCGPDFContextAuthor: "Testing PDFs",
            // Title of the PDF.
            kCGPDFContextTitle: "Lorem Ipsum"
            // etc.
        ]
        
        // Creates a new PDF file at path.
        UIGraphicsBeginPDFContextToFile(filePath, CGRect.zero, pdfMetadata)
        
        // Creates a new page in the current PDF context.
        UIGraphicsBeginPDFPage()
        
        // Default size of the page is 612x72.
        let pageSize = UIGraphicsGetPDFContextBounds().size
        // Custom fonts
        let fontTitle = UIFont.preferredFont(forTextStyle: .largeTitle)
        
        let fontSubject = UIFont.preferredFont(forTextStyle: .title1)
        
        // Drawing the title of the PDF on top of the page.
        let attributedPDFTitle = NSAttributedString(string: pdfTitle, attributes: [NSAttributedString.Key.font: fontTitle])
        let stringSize = attributedPDFTitle.size()
        let stringRect = CGRect(x: (pageSize.width / 2 - stringSize.width / 2), y: 20, width: stringSize.width, height: stringSize.height)
        attributedPDFTitle.draw(in: stringRect)
        
        // Drawing the subject below
        let attributedPDFSubject = NSAttributedString(string: pdfSubject, attributes: [NSAttributedString.Key.font: fontSubject])
        let stringSizeSubject = attributedPDFSubject.size()
        let stringRectSubject = CGRect(x: 20, y: 100, width: stringSizeSubject.width, height: stringSizeSubject.height)
        attributedPDFSubject.draw(in: stringRectSubject)
        
        // Closes the current PDF context and ends writing to the file.
        UIGraphicsEndPDFContext()
        messageCreatedPDF()
    }
    
    @IBAction func viewPDF(_ sender: Any) {
        //In case of clicking View before Create
        guard filePath != "" else {
            messageErrorPDF()
            return
        }
        let pdfView = PDFView(frame: view.bounds)
        pdfView.autoScales = true
        pdfView.tag = 100 //We assign tag 100 to control it in the removeSubView
        view.addSubview(pdfView)
        let pdfDocument = PDFDocument(url: URL(fileURLWithPath: filePath))!
        pdfView.document = pdfDocument
        
        //So that the visualization disappears when pressing on the screen
        let tapGesture = UITapGestureRecognizer(target:self, action: #selector(removeSubView))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func removeSubView(){
        if let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }else{
            print("Don't removing anything")
        }
    }
    
    func messageCreatedPDF() {
        let alert = UIAlertController(title: "PDF Created", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func messageErrorPDF() {
        let alert = UIAlertController(title: "Error", message: "First you have to create the PDF", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func sharePDF(_ sender: Any) {
        //In case of clicking Share before Create
        guard filePath != "" else {
            messageErrorPDF()
            return
        }
        let dc = UIDocumentInteractionController(url: URL(fileURLWithPath: filePath))
        dc.delegate = self
        dc.presentPreview(animated: true)
    }

    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}

