//
//  Copyright (c) 2015 Algolia
//  http://www.algolia.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import AlgoliaSearch
import XCTest

class QueryTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Build & parse
    
    /// Test serializing a query into a URL query string.
    func testBuild() {
        let query = Query()
        query["c"] = "C"
        query["b"] = "B"
        query["a"] = "A"
        let queryString = query.build()
        XCTAssertEqual(queryString, "a=A&b=B&c=C")
    }

    /// Test parsing a query from a URL query string.
    func testParse() {
        // Build the URL for a query.
        let query1 = Query()
        query1["foo"] = "bar"
        query1["abc"] = "xyz"
        let queryString = query1.build()
        
        // Parse the URL into another query.
        let query2 = Query.parse(queryString)
        XCTAssertEqual(query1, query2)
    }

    /// Test that non-ASCII and special characters are escaped.
    func testEscape() {
        let query1 = Query()
        query1.set("accented", value: "éêèàôù")
        query1.set("escaped", value: " %&=#+")
        let queryString = query1.build()
        XCTAssertEqual(queryString, "accented=%C3%A9%C3%AA%C3%A8%C3%A0%C3%B4%C3%B9&escaped=%20%25%26%3D%23%2B")
        
        // Test parsing of escaped characters.
        let query2 = Query.parse(queryString)
        XCTAssertEqual(query1, query2)
    }
    
    // MARK: Low-level
    
    /// Test low-level accessors.
    func testGetSet() {
        let query = Query()
        
        // Test accessors.
        query.set("a", value: "A")
        XCTAssertEqual(query.get("a"), "A")
        
        // Test subscript.
        query["b"] = "B"
        XCTAssertEqual(query["b"], "B")

        // Test subscript and accessors equivalence.
        query.set("c", value: "C")
        XCTAssertEqual(query["c"], "C")
        query["d"] = "D"
        XCTAssertEqual(query.get("d"), "D")

        // Test setting nil.
        query.set("a", value: nil)
        XCTAssertNil(query.get("a"))
        query["b"] = nil
        XCTAssertNil(query["b"])
    }

    // MARK: High-level

    func test_minWordSizefor1Typo() {
        let query1 = Query()
        XCTAssertNil(query1.minWordSizefor1Typo)
        query1.minWordSizefor1Typo = 123
        XCTAssertEqual(query1.minWordSizefor1Typo, 123)
        XCTAssertEqual(query1["minWordSizefor1Typo"], "123")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.minWordSizefor1Typo, 123)
    }

    func test_minWordSizefor2Typos() {
        let query1 = Query()
        XCTAssertNil(query1.minWordSizefor2Typos)
        query1.minWordSizefor2Typos = 456
        XCTAssertEqual(query1.minWordSizefor2Typos, 456)
        XCTAssertEqual(query1["minWordSizefor2Typos"], "456")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.minWordSizefor2Typos, 456)
    }

    func test_minProximity() {
        let query1 = Query()
        XCTAssertNil(query1.minProximity)
        query1.minProximity = 999
        XCTAssertEqual(query1.minProximity, 999)
        XCTAssertEqual(query1["minProximity"], "999")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.minProximity, 999)
    }

    func test_getRankingInfo() {
        let query1 = Query()
        XCTAssertNil(query1.getRankingInfo)
        query1.getRankingInfo = true
        XCTAssertEqual(query1.getRankingInfo, true)
        XCTAssertEqual(query1["getRankingInfo"], "true")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.getRankingInfo, true)

        query1.getRankingInfo = false
        XCTAssertEqual(query1.getRankingInfo, false)
        XCTAssertEqual(query1["getRankingInfo"], "false")
        let query3 = Query.parse(query1.build())
        XCTAssertEqual(query3.getRankingInfo, false)
    }

    func test_ignorePlurals() {
        let query1 = Query()
        XCTAssertNil(query1.ignorePlurals)
        query1.ignorePlurals = true
        XCTAssertEqual(query1.ignorePlurals, true)
        XCTAssertEqual(query1["ignorePlurals"], "true")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.ignorePlurals, true)
        
        query1.ignorePlurals = false
        XCTAssertEqual(query1.ignorePlurals, false)
        XCTAssertEqual(query1["ignorePlurals"], "false")
        let query3 = Query.parse(query1.build())
        XCTAssertEqual(query3.ignorePlurals, false)
    }

    func test_distinct() {
        let query1 = Query()
        XCTAssertNil(query1.distinct)
        query1.distinct = 100
        XCTAssertEqual(query1.distinct, 100)
        XCTAssertEqual(query1["distinct"], "100")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.distinct, 100)
    }

    func test_page() {
        let query1 = Query()
        XCTAssertNil(query1.page)
        query1.page = 0
        XCTAssertEqual(query1.page, 0)
        XCTAssertEqual(query1["page"], "0")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.page, 0)
    }

    func test_hitsPerPage() {
        let query1 = Query()
        XCTAssertNil(query1.hitsPerPage)
        query1.hitsPerPage = 50
        XCTAssertEqual(query1.hitsPerPage, 50)
        XCTAssertEqual(query1["hitsPerPage"], "50")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.hitsPerPage, 50)
    }
    
    func test_allowTyposOnNumericTokens() {
        let query1 = Query()
        XCTAssertNil(query1.allowTyposOnNumericTokens)
        query1.allowTyposOnNumericTokens = true
        XCTAssertEqual(query1.allowTyposOnNumericTokens, true)
        XCTAssertEqual(query1["allowTyposOnNumericTokens"], "true")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.allowTyposOnNumericTokens, true)
        
        query1.allowTyposOnNumericTokens = false
        XCTAssertEqual(query1.allowTyposOnNumericTokens, false)
        XCTAssertEqual(query1["allowTyposOnNumericTokens"], "false")
        let query3 = Query.parse(query1.build())
        XCTAssertEqual(query3.allowTyposOnNumericTokens, false)
    }

    func test_analytics() {
        let query1 = Query()
        XCTAssertNil(query1.analytics)
        query1.analytics = true
        XCTAssertEqual(query1.analytics, true)
        XCTAssertEqual(query1["analytics"], "true")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.analytics, true)
    }
    
    func test_synonyms() {
        let query1 = Query()
        XCTAssertNil(query1.synonyms)
        query1.synonyms = true
        XCTAssertEqual(query1.synonyms, true)
        XCTAssertEqual(query1["synonyms"], "true")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.synonyms, true)
    }

    func test_attributesToHighlight() {
        let query1 = Query()
        XCTAssertNil(query1.attributesToHighlight)
        query1.attributesToHighlight = ["foo", "bar"]
        XCTAssertEqual(query1.attributesToHighlight!, ["foo", "bar"])
        XCTAssertEqual(query1["attributesToHighlight"], "[\"foo\",\"bar\"]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.attributesToHighlight!, ["foo", "bar"])
    }

    func test_attributesToRetrieve() {
        let query1 = Query()
        XCTAssertNil(query1.attributesToRetrieve)
        query1.attributesToRetrieve = ["foo", "bar"]
        XCTAssertEqual(query1.attributesToRetrieve!, ["foo", "bar"])
        XCTAssertEqual(query1["attributesToRetrieve"], "[\"foo\",\"bar\"]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.attributesToRetrieve!, ["foo", "bar"])
    }

    func test_attributesToSnippet() {
        let query1 = Query()
        XCTAssertNil(query1.attributesToSnippet)
        query1.attributesToSnippet = ["foo:3", "bar:7"]
        XCTAssertEqual(query1.attributesToSnippet!, ["foo:3", "bar:7"])
        XCTAssertEqual(query1["attributesToSnippet"], "[\"foo:3\",\"bar:7\"]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.attributesToSnippet!, ["foo:3", "bar:7"])
    }

    func test_query() {
        let query1 = Query()
        XCTAssertNil(query1.query)
        query1.query = "supercalifragilisticexpialidocious"
        XCTAssertEqual(query1.query, "supercalifragilisticexpialidocious")
        XCTAssertEqual(query1["query"], "supercalifragilisticexpialidocious")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.query, "supercalifragilisticexpialidocious")
    }
    
    func test_queryType() {
        let query1 = Query()
        XCTAssertNil(query1.queryType_)
        XCTAssertNil(query1.queryType)

        query1.queryType_ = Query.QueryType.PrefixAll
        XCTAssertEqual(query1.queryType_, Query.QueryType.PrefixAll)
        XCTAssertEqual(query1.queryType, "prefixAll")
        XCTAssertEqual(query1["queryType"], "prefixAll")
        var query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.queryType_, Query.QueryType.PrefixAll)

        query1.queryType_ = Query.QueryType.PrefixLast
        XCTAssertEqual(query1.queryType_, Query.QueryType.PrefixLast)
        XCTAssertEqual(query1.queryType, "prefixLast")
        XCTAssertEqual(query1["queryType"], "prefixLast")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.queryType_, Query.QueryType.PrefixLast)

        query1.queryType_ = Query.QueryType.PrefixNone
        XCTAssertEqual(query1.queryType_, Query.QueryType.PrefixNone)
        XCTAssertEqual(query1.queryType, "prefixNone")
        XCTAssertEqual(query1["queryType"], "prefixNone")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.queryType_, Query.QueryType.PrefixNone)

        query1["queryType"] = "invalid"
        XCTAssertNil(query1.queryType_)
        XCTAssertNil(query1.queryType)

        query1.queryType = "prefixAll"
        XCTAssertEqual(query1.queryType_, Query.QueryType.PrefixAll)
        XCTAssertEqual(query1.queryType, "prefixAll")
        XCTAssertEqual(query1["queryType"], "prefixAll")

        query1.queryType = "invalid"
        XCTAssertNil(query1["queryType"])
        XCTAssertNil(query1.queryType_)
        XCTAssertNil(query1.queryType)
    }

    func test_removeWordsIfNoResults() {
        let query1 = Query()
        XCTAssertNil(query1.removeWordsIfNoResults_)
        XCTAssertNil(query1.removeWordsIfNoResults)
        
        query1.removeWordsIfNoResults_ = Query.RemoveWordsIfNoResults.AllOptional
        XCTAssertEqual(query1.removeWordsIfNoResults_, Query.RemoveWordsIfNoResults.AllOptional)
        XCTAssertEqual(query1.removeWordsIfNoResults, Query.RemoveWordsIfNoResults.AllOptional.rawValue)
        XCTAssertEqual(query1["removeWordsIfNoResults"], "allOptional")
        var query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.removeWordsIfNoResults_, Query.RemoveWordsIfNoResults.AllOptional)
        
        query1.removeWordsIfNoResults_ = Query.RemoveWordsIfNoResults.FirstWords
        XCTAssertEqual(query1.removeWordsIfNoResults_, Query.RemoveWordsIfNoResults.FirstWords)
        XCTAssertEqual(query1.removeWordsIfNoResults, Query.RemoveWordsIfNoResults.FirstWords.rawValue)
        XCTAssertEqual(query1["removeWordsIfNoResults"], "firstWords")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.removeWordsIfNoResults_, Query.RemoveWordsIfNoResults.FirstWords)
        
        query1.removeWordsIfNoResults_ = Query.RemoveWordsIfNoResults.LastWords
        XCTAssertEqual(query1.removeWordsIfNoResults_, Query.RemoveWordsIfNoResults.LastWords)
        XCTAssertEqual(query1.removeWordsIfNoResults, Query.RemoveWordsIfNoResults.LastWords.rawValue)
        XCTAssertEqual(query1["removeWordsIfNoResults"], "lastWords")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.removeWordsIfNoResults_, Query.RemoveWordsIfNoResults.LastWords)
        
        query1.removeWordsIfNoResults_ = Query.RemoveWordsIfNoResults.None
        XCTAssertEqual(query1.removeWordsIfNoResults_, Query.RemoveWordsIfNoResults.None)
        XCTAssertEqual(query1.removeWordsIfNoResults, Query.RemoveWordsIfNoResults.None.rawValue)
        XCTAssertEqual(query1["removeWordsIfNoResults"], "none")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.removeWordsIfNoResults_, Query.RemoveWordsIfNoResults.None)
        
        query1["removeWordsIfNoResults"] = "invalid"
        XCTAssertNil(query1.removeWordsIfNoResults_)
        XCTAssertNil(query1.removeWordsIfNoResults)
        
        query1.removeWordsIfNoResults = "allOptional"
        XCTAssertEqual(query1.removeWordsIfNoResults_, Query.RemoveWordsIfNoResults.AllOptional)
        XCTAssertEqual(query1.removeWordsIfNoResults, Query.RemoveWordsIfNoResults.AllOptional.rawValue)
        XCTAssertEqual(query1["removeWordsIfNoResults"], "allOptional")
        
        query1.removeWordsIfNoResults = "invalid"
        XCTAssertNil(query1["removeWordsIfNoResults"])
        XCTAssertNil(query1.removeWordsIfNoResults_)
        XCTAssertNil(query1.removeWordsIfNoResults)
    }
    
    func test_typoTolerance() {
        let query1 = Query()
        XCTAssertNil(query1.typoTolerance_)
        XCTAssertNil(query1.typoTolerance)
        
        query1.typoTolerance_ = Query.TypoTolerance.True
        XCTAssertEqual(query1.typoTolerance_, Query.TypoTolerance.True)
        XCTAssertEqual(query1.typoTolerance, Query.TypoTolerance.True.rawValue)
        XCTAssertEqual(query1["typoTolerance"], "true")
        var query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.typoTolerance_, Query.TypoTolerance.True)
        
        query1.typoTolerance_ = Query.TypoTolerance.False
        XCTAssertEqual(query1.typoTolerance_, Query.TypoTolerance.False)
        XCTAssertEqual(query1.typoTolerance, Query.TypoTolerance.False.rawValue)
        XCTAssertEqual(query1["typoTolerance"], "false")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.typoTolerance_, Query.TypoTolerance.False)
        
        query1.typoTolerance_ = Query.TypoTolerance.Min
        XCTAssertEqual(query1.typoTolerance_, Query.TypoTolerance.Min)
        XCTAssertEqual(query1.typoTolerance, Query.TypoTolerance.Min.rawValue)
        XCTAssertEqual(query1["typoTolerance"], "min")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.typoTolerance_, Query.TypoTolerance.Min)
        
        query1.typoTolerance_ = Query.TypoTolerance.Strict
        XCTAssertEqual(query1.typoTolerance_, Query.TypoTolerance.Strict)
        XCTAssertEqual(query1.typoTolerance, Query.TypoTolerance.Strict.rawValue)
        XCTAssertEqual(query1["typoTolerance"], "strict")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.typoTolerance_, Query.TypoTolerance.Strict)
        
        query1["typoTolerance"] = "invalid"
        XCTAssertNil(query1.typoTolerance_)
        XCTAssertNil(query1.typoTolerance)
        
        query1.typoTolerance = "true"
        XCTAssertEqual(query1.typoTolerance_, Query.TypoTolerance.True)
        XCTAssertEqual(query1.typoTolerance, Query.TypoTolerance.True.rawValue)
        XCTAssertEqual(query1["typoTolerance"], "true")
        
        query1.typoTolerance = "invalid"
        XCTAssertNil(query1["typoTolerance"])
        XCTAssertNil(query1.typoTolerance_)
        XCTAssertNil(query1.typoTolerance)
    }

    func test_facets() {
        let query1 = Query()
        XCTAssertNil(query1.facets)
        query1.facets = ["foo", "bar"]
        XCTAssertEqual(query1.facets!, ["foo", "bar"])
        XCTAssertEqual(query1["facets"], "[\"foo\",\"bar\"]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.facets!, ["foo", "bar"])
    }

    func test_optionalWords() {
        let query1 = Query()
        XCTAssertNil(query1.optionalWords)
        query1.optionalWords = ["foo", "bar"]
        XCTAssertEqual(query1.optionalWords!, ["foo", "bar"])
        XCTAssertEqual(query1["optionalWords"], "[\"foo\",\"bar\"]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.optionalWords!, ["foo", "bar"])
    }

    func test_restrictSearchableAttributes() {
        let query1 = Query()
        XCTAssertNil(query1.restrictSearchableAttributes)
        query1.restrictSearchableAttributes = ["foo", "bar"]
        XCTAssertEqual(query1.restrictSearchableAttributes!, ["foo", "bar"])
        XCTAssertEqual(query1["restrictSearchableAttributes"], "[\"foo\",\"bar\"]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.restrictSearchableAttributes!, ["foo", "bar"])
    }

    func test_highlightPreTag() {
        let query1 = Query()
        XCTAssertNil(query1.highlightPreTag)
        query1.highlightPreTag = "<PRE["
        XCTAssertEqual(query1.highlightPreTag, "<PRE[")
        XCTAssertEqual(query1["highlightPreTag"], "<PRE[")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.highlightPreTag, "<PRE[")
    }
    
    func test_highlightPostTag() {
        let query1 = Query()
        XCTAssertNil(query1.highlightPostTag)
        query1.highlightPostTag = "]POST>"
        XCTAssertEqual(query1.highlightPostTag, "]POST>")
        XCTAssertEqual(query1["highlightPostTag"], "]POST>")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.highlightPostTag, "]POST>")
    }
    
    func test_snippetEllipsisText() {
        let query1 = Query()
        XCTAssertNil(query1.snippetEllipsisText)
        query1.snippetEllipsisText = "…"
        XCTAssertEqual(query1.snippetEllipsisText, "…")
        XCTAssertEqual(query1["snippetEllipsisText"], "…")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.snippetEllipsisText, "…")
    }
    
    func test_analyticsTags() {
        let query1 = Query()
        XCTAssertNil(query1.analyticsTags)
        query1.analyticsTags = ["foo", "bar"]
        XCTAssertEqual(query1.analyticsTags!, ["foo", "bar"])
        XCTAssertEqual(query1["analyticsTags"], "[\"foo\",\"bar\"]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.analyticsTags!, ["foo", "bar"])
    }
    
    func test_disableTypoToleranceOnAttributes() {
        let query1 = Query()
        XCTAssertNil(query1.disableTypoToleranceOnAttributes)
        query1.disableTypoToleranceOnAttributes = ["foo", "bar"]
        XCTAssertEqual(query1.disableTypoToleranceOnAttributes!, ["foo", "bar"])
        XCTAssertEqual(query1["disableTypoToleranceOnAttributes"], "[\"foo\",\"bar\"]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.disableTypoToleranceOnAttributes!, ["foo", "bar"])
    }

    func test_aroundPrecision() {
        let query1 = Query()
        XCTAssertNil(query1.aroundPrecision)
        query1.aroundPrecision = 12345
        XCTAssertEqual(query1.aroundPrecision, 12345)
        XCTAssertEqual(query1["aroundPrecision"], "12345")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.aroundPrecision, 12345)
    }
    
    func test_aroundRadius() {
        let query1 = Query()
        XCTAssertNil(query1.aroundRadius)
        query1.aroundRadius = 987
        XCTAssertEqual(query1.aroundRadius, 987)
        XCTAssertEqual(query1["aroundRadius"], "987")
        var query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.aroundRadius, 987)
        
        query1.aroundRadius = Query.aroundRadiusAll
        XCTAssertEqual(query1.aroundRadius, Query.aroundRadiusAll)
        XCTAssertEqual(query1["aroundRadius"], "all")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.aroundRadius, Query.aroundRadiusAll)
    }
    
    func test_aroundLatLngViaIP() {
        let query1 = Query()
        XCTAssertNil(query1.aroundLatLngViaIP)
        query1.aroundLatLngViaIP = true
        XCTAssertEqual(query1.aroundLatLngViaIP, true)
        XCTAssertEqual(query1["aroundLatLngViaIP"], "true")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.aroundLatLngViaIP, true)
    }
    
    func test_aroundLatLng() {
        let query1 = Query()
        XCTAssertNil(query1.aroundLatLng)
        query1.aroundLatLng = LatLng(lat: 89.76, lng: -123.45)
        XCTAssertEqual(query1.aroundLatLng!, LatLng(lat: 89.76, lng: -123.45))
        XCTAssertEqual(query1["aroundLatLng"], "89.76,-123.45")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.aroundLatLng!, LatLng(lat: 89.76, lng: -123.45))
    }
    
    func test_insideBoundingBox() {
        let query1 = Query()
        XCTAssertNil(query1.insideBoundingBox)
        let box1 = GeoRect(p1: LatLng(lat: 11.111111, lng: 22.222222), p2: LatLng(lat: 33.333333, lng: 44.444444))
        query1.insideBoundingBox = [box1]
        XCTAssertEqual(query1.insideBoundingBox!, [box1])
        XCTAssertEqual(query1["insideBoundingBox"], "11.111111,22.222222,33.333333,44.444444")
        var query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.insideBoundingBox!, [box1])
        
        let box2 = GeoRect(p1: LatLng(lat: -55.555555, lng: -66.666666), p2: LatLng(lat: -77.777777, lng: -88.888888))
        let boxes = [box1, box2]
        query1.insideBoundingBox = boxes
        XCTAssertEqual(query1.insideBoundingBox!, boxes)
        XCTAssertEqual(query1["insideBoundingBox"], "11.111111,22.222222,33.333333,44.444444,-55.555555,-66.666666,-77.777777,-88.888888")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.insideBoundingBox!, boxes)
    }

    func test_insidePolygon() {
        let query1 = Query()
        XCTAssertNil(query1.insidePolygon)
        let box = [LatLng(lat: 11.111111, lng: 22.222222), LatLng(lat: 33.333333, lng: 44.444444), LatLng(lat: -55.555555, lng: -66.666666)]
        query1.insidePolygon = box
        XCTAssertEqual(query1.insidePolygon!, box)
        XCTAssertEqual(query1["insidePolygon"], "11.111111,22.222222,33.333333,44.444444,-55.555555,-66.666666")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.insidePolygon!, box)
    }

    func test_tagFilters() {
        let VALUE: [AnyObject] = ["tag1", ["tag2", "tag3"]]
        let query1 = Query()
        XCTAssertNil(query1.tagFilters)
        query1.tagFilters = VALUE
        XCTAssertEqual(query1.tagFilters! as NSObject, VALUE as NSObject)
        XCTAssertEqual(query1["tagFilters"], "[\"tag1\",[\"tag2\",\"tag3\"]]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.tagFilters! as NSObject, VALUE as NSObject)
    }
    
    func test_facetFilters() {
        let VALUE: [AnyObject] = [["category:Book", "category:Movie"], "author:John Doe"]
        let query1 = Query()
        XCTAssertNil(query1.facetFilters)
        query1.facetFilters = VALUE
        XCTAssertEqual(query1.facetFilters! as NSObject, VALUE as NSObject)
        XCTAssertEqual(query1["facetFilters"], "[[\"category:Book\",\"category:Movie\"],\"author:John Doe\"]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.facetFilters! as NSObject, VALUE as NSObject)
    }

    func test_advancedSyntax() {
        let query1 = Query()
        XCTAssertNil(query1.advancedSyntax)
        query1.advancedSyntax = true
        XCTAssertEqual(query1.advancedSyntax, true)
        XCTAssertEqual(query1["advancedSyntax"], "true")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.advancedSyntax, true)
    }

    func test_removeStopWords() {
        let query1 = Query()
        XCTAssertNil(query1.removeStopWords)
        query1.removeStopWords = true
        XCTAssertEqual(query1.removeStopWords as? Bool, true)
        XCTAssertEqual(query1["removeStopWords"], "true")
        var query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.removeStopWords as? Bool, true)

        query1.removeStopWords = false
        XCTAssertEqual(query1.removeStopWords as? Bool, false)
        XCTAssertEqual(query1["removeStopWords"], "false")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.removeStopWords as? Bool, false)

        let VALUE = ["de", "es", "fr"]
        query1.removeStopWords = VALUE
        XCTAssertEqual(query1.removeStopWords as! [String], VALUE)
        XCTAssertEqual(query1["removeStopWords"], "de,es,fr")
        query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.removeStopWords as! [String], VALUE)
    }
    
    func test_maxValuesPerFacet() {
        let query1 = Query()
        XCTAssertNil(query1.maxValuesPerFacet)
        query1.maxValuesPerFacet = 456
        XCTAssertEqual(query1.maxValuesPerFacet, 456)
        XCTAssertEqual(query1["maxValuesPerFacet"], "456")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.maxValuesPerFacet, 456)
    }
    
    func test_minimumAroundRadius() {
        let query1 = Query()
        XCTAssertNil(query1.minimumAroundRadius)
        query1.minimumAroundRadius = 1000
        XCTAssertEqual(query1.minimumAroundRadius, 1000)
        XCTAssertEqual(query1["minimumAroundRadius"], "1000")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.minimumAroundRadius, 1000)
    }
    
    func test_numericFilters() {
        let VALUE: [AnyObject] = ["code=1", ["price:0 to 10", "price:1000 to 2000"]]
        let query1 = Query()
        XCTAssertNil(query1.numericFilters)
        query1.numericFilters = VALUE
        XCTAssertEqual(query1.numericFilters! as NSObject, VALUE as NSObject)
        XCTAssertEqual(query1["numericFilters"], "[\"code=1\",[\"price:0 to 10\",\"price:1000 to 2000\"]]")
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.numericFilters! as NSObject, VALUE as NSObject)
    }
    
    func test_filters() {
        let VALUE = "available=1 AND (category:Book OR NOT category:Ebook) AND publication_date: 1441745506 TO 1441755506 AND inStock > 0 AND author:\"John Doe\""
        let query1 = Query()
        XCTAssertNil(query1.filters)
        query1.filters = VALUE
        XCTAssertEqual(query1.filters, VALUE)
        XCTAssertEqual(query1["filters"], VALUE)
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.filters, VALUE)
    }
    
    func test_exactOnSingleWordQuery() {
        let query1 = Query()
        XCTAssertNil(query1.exactOnSingleWordQuery_)
        XCTAssertNil(query1.exactOnSingleWordQuery)
        
        let ALL_VALUES = [Query.ExactOnSingleWordQuery.None, Query.ExactOnSingleWordQuery.Word, Query.ExactOnSingleWordQuery.Attribute]
        for value in ALL_VALUES {
            query1.exactOnSingleWordQuery_ = value
            XCTAssertEqual(query1.exactOnSingleWordQuery_, value)
            XCTAssertEqual(query1.exactOnSingleWordQuery, value.rawValue)
            XCTAssertEqual(query1["exactOnSingleWordQuery"], value.rawValue)
            let query2 = Query.parse(query1.build())
            XCTAssertEqual(query2.exactOnSingleWordQuery_, value)
            
            query1.exactOnSingleWordQuery = value.rawValue
            XCTAssertEqual(query1.exactOnSingleWordQuery_, value)
            XCTAssertEqual(query1.exactOnSingleWordQuery, value.rawValue)
            XCTAssertEqual(query1["exactOnSingleWordQuery"], value.rawValue)
        }
        
        query1["exactOnSingleWordQuery"] = "invalid"
        XCTAssertNil(query1.exactOnSingleWordQuery_)
        XCTAssertNil(query1.exactOnSingleWordQuery)
        
        query1.exactOnSingleWordQuery = "invalid"
        XCTAssertNil(query1["exactOnSingleWordQuery"])
        XCTAssertNil(query1.exactOnSingleWordQuery_)
        XCTAssertNil(query1.exactOnSingleWordQuery)
    }
    
    func test_alternativesAsExact() {
        let query1 = Query()
        XCTAssertNil(query1.alternativesAsExact_)
        XCTAssertNil(query1.alternativesAsExact)

        let VALUES = [Query.AlternativesAsExact.IgnorePlurals, Query.AlternativesAsExact.SingleWordSynonym, Query.AlternativesAsExact.MultiWordsSynonym]
        let RAW_VALUES = ["ignorePlurals", "singleWordSynonym", "multiWordsSynonym"]
        query1.alternativesAsExact_ = VALUES
        XCTAssertEqual(query1.alternativesAsExact_!, VALUES)
        XCTAssertEqual(query1.alternativesAsExact!, RAW_VALUES)
        XCTAssertEqual(query1["alternativesAsExact"], RAW_VALUES.joined(separator: ","))
        let query2 = Query.parse(query1.build())
        XCTAssertEqual(query2.alternativesAsExact_!, VALUES)
        
        query1.alternativesAsExact = RAW_VALUES
        XCTAssertEqual(query1.alternativesAsExact_!, VALUES)
        XCTAssertEqual(query1.alternativesAsExact!, RAW_VALUES)
        XCTAssertEqual(query1["alternativesAsExact"], RAW_VALUES.joined(separator: ","))
    }
}
