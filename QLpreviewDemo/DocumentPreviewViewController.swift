//
//  ViewController.swift
//  QLpreviewDemo
//
//  Created by Faiz Ul Hassan on 26/01/2024.
//

import UIKit
import QuickLook
import Foundation

class DocumentPreviewViewController: UIViewController {
    
    // MARK: - Properties
    
    var documentPreviewItem: URL?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup if needed
    }
    
    // MARK: - Actions
    
    @IBAction func displayLocalDocument(_ sender: UIButton) {
        let documentName = "sample_form.pdf"
        documentPreviewItem = getPreviewItemForLocalDocument(named: documentName)
        presentPreviewController()
    }
    
    @IBAction func displayDocumentFromURL(_ sender: UIButton) {
        downloadDocument { [weak self] success, fileLocation in
            guard let self = self else { return }
            if success {
                self.documentPreviewItem = fileLocation
                self.presentPreviewController()
            } else {
                self.handleDocumentDownloadError()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getPreviewItemForLocalDocument(named name: String) -> URL? {
        let url = URL(fileURLWithPath: name)
        
        // Extract filename and extension from the provided URL
        let filename = url.deletingPathExtension().lastPathComponent
        let fileExtension = url.pathExtension
        
        // Check if the file exists in the app bundle
        guard let path = Bundle.main.path(forResource: filename, ofType: fileExtension) else {
            return nil
        }
        
        return URL(fileURLWithPath: path)
    }
    
    
    private func downloadDocument(completion: @escaping (Bool, URL?) -> Void) {
        // URL of the document to be downloaded
        let documentURL = URL(string: "https://carleton.ca/financialservices/wp-content/uploads/sample_signature_form_carleton_u_v5.pdf")!
        
        // Target file name and URL in the documents directory
        let targetFileName = "filename.pdf"
        
        // Get the documents directory URL
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completion(false, nil)
            return
        }
        
        // Append the target file name to the documents directory URL
        let targetDocumentURL = documentsDirectoryURL.appendingPathComponent(targetFileName)
        
        // Check if the document already exists at the target path
        if FileManager.default.fileExists(atPath: targetDocumentURL.path) {
            print("Document already exists at path")
            completion(true, targetDocumentURL)
        } else {
            // Download the document using URLSession
            URLSession.shared.downloadTask(with: documentURL) { location, response, error in
                guard let location = location, error == nil else {
                    // Handle the download error
                    completion(false, nil)
                    return
                }
                
                do {
                    // Move the downloaded document to the target location
                    try FileManager.default.moveItem(at: location, to: targetDocumentURL)
                    print("Document moved to documents folder")
                    completion(true, targetDocumentURL)
                } catch {
                    // Handle the move operation error
                    print(error.localizedDescription)
                    completion(false, nil)
                }
            }.resume()
        }
    }
    
    
    
    private func presentPreviewController() {
        
        DispatchQueue.main.async {
            let previewController = QLPreviewController()
            previewController.dataSource = self
            if #available(iOS 13.0, *) {
                previewController.delegate = self
            }
            previewController.isEditing = true
            previewController.setEditing(true, animated: true)
            self.present(previewController, animated: true)
        }
        
    }
    
    private func handleDocumentDownloadError() {
        debugPrint("Document download failed")
        // Present an appropriate error message to the user
    }
}

// MARK: - QLPreviewControllerDataSource

extension DocumentPreviewViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return documentPreviewItem! as QLPreviewItem
    }
}

// MARK: - QLPreviewControllerDelegate (available in iOS 13.0 and later)

@available(iOS 13.0, *)
extension DocumentPreviewViewController: QLPreviewControllerDelegate {
    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        return .updateContents
    }
    
    func previewController(_ controller: QLPreviewController, didUpdateContentsOf previewItem: QLPreviewItem) {
        print("Document updated")
    }
    
}
