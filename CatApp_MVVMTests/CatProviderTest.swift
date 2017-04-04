//
//  CatProviderTest.swift
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

class CatProviderTest: XCTestCase {
    
    var catProvider: CatProvider!
    
    override func setUp() {
        super.setUp()
        catProvider = CatProvider()
    }
    
    func testNetworkErrorRequestCat() {
        let stubCatProvider = prepeareStubNetworkErrorFor(catProvider: catProvider)
        let expectation = self.expectation(description: "network error")

        catProvider.createNewCat { (cat, success, error) in
            XCTAssertFalse(success)
            XCTAssertEqual(error, CatLoadingError.networkError)
            XCTAssertNil(cat)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10) { (error) in
            self.removeStub(stubCatProvider)
            XCTAssertNil(error)
        }
    }
    
    func testServerErrorRequestCat() {
        let stubCatProvider = prepeareStubServerErrorFor(catProvider: catProvider)
        let expectation = self.expectation(description: "server error")
        
        catProvider.createNewCat { (cat, success, error) in
            XCTAssertFalse(success)
            XCTAssertEqual(error, CatLoadingError.serverError)
            XCTAssertNil(cat)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10) { (error) in
            self.removeStub(stubCatProvider)
            XCTAssertNil(error)
        }
    }

    func testEmptyJSONResponse() {
        let stubCatProvider = prepeareStubEmptyJSONFor(catProvider: catProvider)
        let expectation = self.expectation(description: "server error")
        
        catProvider.createNewCat { (cat, success, error) in
            XCTAssertFalse(success)
            XCTAssertNil(cat)
            XCTAssertEqual(error, CatLoadingError.formatError)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10) { (error) in
            self.removeStub(stubCatProvider)
            XCTAssertNil(error)
        }
    }

    func testCancell() {
        let stubLoadCatOK = prepeareStubLoadJsonOK(catProvider: catProvider)
        let expectation = self.expectation(description: "cancelled")

        catProvider.createNewCat { (cat, success, error) in
            XCTAssertNil(cat)
            XCTAssertFalse(success)
            XCTAssertEqual(error, CatLoadingError.cancelled)
            expectation.fulfill()
        }

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.catProvider.cancel()
        }

        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error)
            self.removeStub(stubLoadCatOK)
        }
    }
    
    func testWhileProcess() {
        let expectation = self.expectation(description: "LoadCat")
        catProvider.createNewCat { (cat, success, error) in
            XCTAssert(success)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error)
        }
    }

}
