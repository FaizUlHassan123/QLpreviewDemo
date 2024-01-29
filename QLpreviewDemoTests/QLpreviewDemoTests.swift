//
//  QLpreviewDemoTests.swift
//  QLpreviewDemoTests
//
//  Created by Faiz Ul Hassan on 26/01/2024.
//

import XCTest
@testable import QLpreviewDemo

class DocumentPreviewViewControllerTests: XCTestCase {
    
    var sut: DocumentPreviewViewController!

    override func setUp() {
        super.setUp()
        sut = DocumentPreviewViewController()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Helper Methods
    
    func createMockDocumentURL() -> URL {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectoryURL.appendingPathComponent("sample_form.pdf")
    }

    // MARK: - Test Cases
    
    func testDisplayLocalDocument() {
        sut.displayLocalDocument(UIButton())
        XCTAssertNotNil(sut.documentPreviewItem, "Local document preview item should not be nil after displaying a local document.")
    }

    func testDisplayDocumentFromURL() {
        let expectation = self.expectation(description: "Download document expectation")

        sut.displayDocumentFromURL(UIButton())

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            XCTAssertNotNil(self.sut.documentPreviewItem, "Document preview item should not be nil after displaying a document from URL.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testDownloadDocument() {
        let expectation = self.expectation(description: "Download document expectation")

        sut.downloadDocument { success, fileLocation in
            XCTAssertTrue(success, "Document download should be successful.")
            XCTAssertNotNil(fileLocation, "Document file location should not be nil.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testPresentPreviewController() {
        sut.documentPreviewItem = createMockDocumentURL()
        sut.presentPreviewController()

        // Verify that a QLPreviewController is presented
        XCTAssertTrue(sut.presentedViewController is QLPreviewController, "A QLPreviewController should be presented.")
    }

    // Add more test cases as needed

}
