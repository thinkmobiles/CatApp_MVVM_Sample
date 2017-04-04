//
//  EditCatViewModelTests.swift
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

final class EditCatViewModelTests: XCTestCase {

    var image: UIImage!
    var cat: Cat!
    var viewModel: EditCatViewModel!

    override func setUp() {
        super.setUp()
        image = UIImage(named: EditCatViewModel.Constants.sampleImageName)
        cat = Cat(imageURL: NSURL(), imageData: UIImagePNGRepresentation(image)!)
        viewModel = EditCatViewModel(cat: cat)
    }

    func testFilterSamples() {
        let filtersCount = EditCatViewModel.Constants.filterNames.count

        var expectations = (0..<filtersCount).map {_ in
            self.expectation(description: "Filter sample is created")
        }

        viewModel.onUpdateFilterSample = { index in
            let imageData = UIImagePNGRepresentation(self.viewModel.filterSample(at: index))
            for i in 0..<filtersCount {
                if i != index {
                    let otherImageData = UIImagePNGRepresentation(self.viewModel.filterSample(at: i))
                    XCTAssertNotEqual(imageData, otherImageData)
                }
            }
            expectations.removeFirst().fulfill()
        }

        viewModel.createFilterSamples()

        XCTAssertFalse(viewModel.isProcessing.value)
        XCTAssertNotNil(viewModel.image.value)

        waitForExpectations(timeout: 20) { (error) in
            XCTAssertNil(error)
        }
    }

    func testApplayFilter() {
        let filtersCount = EditCatViewModel.Constants.filterNames.count

        let createFilterSamlesExpectation = expectation(description: "Create filter samples")

        viewModel.onUpdateFilterSample = { index in
            if index == filtersCount - 1 {
                createFilterSamlesExpectation.fulfill()
            }
        }

        viewModel.createFilterSamples()

        waitForExpectations(timeout: 20) { (error) in
            XCTAssertNil(error)
        }

        for i in 0..<filtersCount {
            let initailStateIdentifier = "Initial State"
            let filteringInProgressStateIdentifier = "Filtering in progress"
            let filteringFinishedStateIdentifier = "Filtering finished"

            let expectationInitialState = expectation(description: initailStateIdentifier)
            let expectationLoadInProgress = expectation(description: filteringInProgressStateIdentifier)
            let expectationLoadFinished = expectation(description: filteringFinishedStateIdentifier)

            var expectations = [expectationInitialState, expectationLoadInProgress, expectationLoadFinished]

            let bindingTocken = viewModel.isProcessing.observeNext { (isProcessing) in
                guard let expectation = expectations.first else {
                    XCTFail("Expected expectation")
                    return
                }
                expectations.removeFirst()

                switch expectation.description {
                case initailStateIdentifier:
                    XCTAssertFalse(self.viewModel.isProcessing.value)

                case filteringInProgressStateIdentifier:
                    XCTAssertTrue(self.viewModel.isProcessing.value)

                case filteringFinishedStateIdentifier:
                    XCTAssertFalse(self.viewModel.isProcessing.value)
                    let sampleImageData = UIImagePNGRepresentation(self.viewModel.filterSample(at: i))
                    XCTAssertNotNil(self.viewModel.image.value)
                    let filteredImageData = UIImagePNGRepresentation(self.viewModel.image.value!)
                    XCTAssertEqual(sampleImageData, filteredImageData)
                default:
                    XCTFail("Unknown expectation")
                }
                expectation.fulfill()
            }


            viewModel.applyFilter(at: i)

            waitForExpectations(timeout: 10) { (error) in
                bindingTocken.dispose()
                XCTAssertNil(error)
            }

        }
    }
}
