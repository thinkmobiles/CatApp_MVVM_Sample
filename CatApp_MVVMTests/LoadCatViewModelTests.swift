//
//  LoadCatViewModelTests.swift
//
//  Created by R. Fogash, V. Ahosta
//  Copyright (c) 2017 Thinkmobiles
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import XCTest
@testable import CatApp_MVVM

class LoadCatViewModelTests: XCTestCase {

    var catProvider: CatProvider!
    var catViewModel: LoadCatViewModel!

    override func setUp() {
        super.setUp()
        catProvider = CatProvider()
        catViewModel = LoadCatViewModel(catProvider: catProvider)
    }

    func testCatLoadFailed() {
        let networkErrorStub = prepeareStubServerErrorFor(catProvider: catProvider)

        let initailStateIdentifier = "Initial State"
        let loadInProgressStateIdentifier = "Load in progress"
        let loadFinishedStateIdentifier = "Load finished"

        let expectationInitialState = self.expectation(description: initailStateIdentifier)
        let expectationLoadInProgress = self.expectation(description: loadInProgressStateIdentifier)
        let expectationLoadFinished = self.expectation(description: loadFinishedStateIdentifier)

        var expectations = [expectationInitialState, expectationLoadInProgress, expectationLoadFinished]

        _ = catViewModel.isLoading.observeNext { (isLoading) in
            guard let expectation = expectations.first else {
                XCTFail("Expected expectation")
                return
            }
            expectations.removeFirst()

            switch expectation.description {
            case initailStateIdentifier:
                XCTAssertFalse(self.catViewModel.isLoading.value)
                XCTAssertNil(self.catViewModel.title.value)
                XCTAssertNil(self.catViewModel.imageData.value)
            case loadInProgressStateIdentifier:
                XCTAssertTrue(self.catViewModel.isLoading.value)
                XCTAssertNil(self.catViewModel.title.value)
                XCTAssertNil(self.catViewModel.imageData.value)
            case loadFinishedStateIdentifier:
                XCTAssertFalse(self.catViewModel.isLoading.value)
                XCTAssertEqual(self.catViewModel.title.value, LoadCatViewModel.ErrorMessages.loadingError)
                XCTAssertNil(self.catViewModel.imageData.value)
            default:
                XCTFail("Unknown expectation")
            }
            expectation.fulfill()
        }

        catViewModel.loadNextCat()

        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error)
            self.removeStub(networkErrorStub)
        }
    }


    func testImageLoadFailed() {
        let catLoadStubOK = self.prepeareStubLoadJsonOK(catProvider: catProvider)
        let imageLoadErrorStub = self.prepeareStubServerErrorForImageRequest()

        let initailStateIdentifier = "Initial State"
        let loadInProgressStateIdentifier = "Load in progress"
        let loadFinishedStateIdentifier = "Load finished"

        let expectationInitialState = self.expectation(description: initailStateIdentifier)
        let expectationLoadInProgress = self.expectation(description: loadInProgressStateIdentifier)
        let expectationLoadFinished = self.expectation(description: loadFinishedStateIdentifier)

        var expectations = [expectationInitialState, expectationLoadInProgress, expectationLoadFinished]

        _ = catViewModel.isLoading.observeNext { (isLoading) in
            guard let expectation = expectations.first else {
                XCTFail("Expected expectation")
                return
            }
            expectations.removeFirst()

            switch expectation.description {
            case initailStateIdentifier:
                XCTAssertFalse(self.catViewModel.isLoading.value)
                XCTAssertNil(self.catViewModel.title.value)
                XCTAssertNil(self.catViewModel.imageData.value)
            case loadInProgressStateIdentifier:
                XCTAssertTrue(self.catViewModel.isLoading.value)
                XCTAssertNil(self.catViewModel.title.value)
                XCTAssertNil(self.catViewModel.imageData.value)
            case loadFinishedStateIdentifier:
                XCTAssertFalse(self.catViewModel.isLoading.value)
                XCTAssertEqual(self.catViewModel.title.value, LoadCatViewModel.ErrorMessages.loadingError)
                XCTAssertNil(self.catViewModel.imageData.value)
            default:
                XCTFail("Unknown expectation")
            }
            expectation.fulfill()
        }

        catViewModel.loadNextCat()

        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error)
            self.removeStub(imageLoadErrorStub)
            self.removeStub(catLoadStubOK)
        }
    }


    func testImageLoadSucceeded() {
        let requestCatOK = self.prepeareStubLoadJsonOK(catProvider: catProvider)
        let requestImageOK = self.prepeareStubForSuccessImageLoadRequest()

        let initailStateIdentifier = "Initial State"
        let loadInProgressStateIdentifier = "Load in progress"
        let loadFinishedStateIdentifier = "Load finished"

        let expectationInitialState = self.expectation(description: initailStateIdentifier)
        let expectationLoadInProgress = self.expectation(description: loadInProgressStateIdentifier)
        let expectationLoadFinished = self.expectation(description: loadFinishedStateIdentifier)

        var expectations = [expectationInitialState, expectationLoadInProgress, expectationLoadFinished]

        _ = catViewModel.isLoading.observeNext { (isLoading) in
            guard let expectation = expectations.first else {
                XCTFail("Expected expectation")
                return
            }
            expectations.removeFirst()

            switch expectation.description {
            case initailStateIdentifier:
                XCTAssertFalse(self.catViewModel.isLoading.value)
                XCTAssertNil(self.catViewModel.title.value)
                XCTAssertNil(self.catViewModel.imageData.value)
            case loadInProgressStateIdentifier:
                XCTAssertTrue(self.catViewModel.isLoading.value)
                XCTAssertNil(self.catViewModel.title.value)
                XCTAssertNil(self.catViewModel.imageData.value)
            case loadFinishedStateIdentifier:
                XCTAssertFalse(self.catViewModel.isLoading.value)
                XCTAssertEqual(self.catViewModel.title.value, ImageFileExtensions.stubImageURLString)
                XCTAssertNotNil(self.catViewModel.imageData.value)
            default:
                XCTFail("Unknown expectation")
            }
            expectation.fulfill()
        }

        catViewModel.loadNextCat()

        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error)
            self.removeStub(requestImageOK)
            self.removeStub(requestCatOK)
        }
    }

    func testCatLoadCancelled() {
        let requestCatOK = self.prepeareStubLoadJsonOK(catProvider: catProvider)
        let requestImageOK = self.prepeareStubForSuccessImageLoadRequest()

        let initailStateIdentifier = "Initial State"
        let loadInProgressStateIdentifier = "Load in progress"
        let loadFinishedStateIdentifier = "Load finished"

        let expectationInitialState = self.expectation(description: initailStateIdentifier)
        let expectationLoadInProgress = self.expectation(description: loadInProgressStateIdentifier)
        let expectationLoadFinished = self.expectation(description: loadFinishedStateIdentifier)

        var expectations = [expectationInitialState, expectationLoadInProgress, expectationLoadFinished]

        _ = catViewModel.isLoading.observeNext { (isLoading) in
            guard let expectation = expectations.first else {
                XCTFail("Expected expectation")
                return
            }
            expectations.removeFirst()

            switch expectation.description {
            case initailStateIdentifier:
                XCTAssertFalse(self.catViewModel.isLoading.value)
                XCTAssertNil(self.catViewModel.title.value)
                XCTAssertNil(self.catViewModel.imageData.value)
            case loadInProgressStateIdentifier:
                XCTAssertTrue(self.catViewModel.isLoading.value)
                XCTAssertNil(self.catViewModel.title.value)
                XCTAssertNil(self.catViewModel.imageData.value)

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.catViewModel.cancelCurrentDownloading()
                }
            case loadFinishedStateIdentifier:
                XCTAssertFalse(self.catViewModel.isLoading.value)
                XCTAssertEqual(self.catViewModel.title.value, LoadCatViewModel.ErrorMessages.cancelled)
                XCTAssertNil(self.catViewModel.imageData.value)
            default:
                XCTFail("Unknown expectation")
            }
            expectation.fulfill()
        }

        catViewModel.loadNextCat()

        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error)
            self.removeStub(requestImageOK)
            self.removeStub(requestCatOK)
        }
    }

}
