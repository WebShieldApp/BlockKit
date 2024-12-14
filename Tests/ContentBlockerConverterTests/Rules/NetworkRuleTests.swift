import Foundation

import XCTest
@testable import ContentBlockerConverter

final class NetworkRuleTests: XCTestCase {
    let START_URL_UNESCAPED = "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?"
    let URL_FILTER_REGEXP_END_SEPARATOR = "([\\/:&\\?].*)?$"
    
    func testNetworkRule() {
        // TODO(ameshkov): !!! Add SafariVersion tests here.

        struct TestCase {
            let ruleText: String
            let expectedUrlRuleText: String
            let expectedUrlRegExpSource: String?
            var expectedWhiteList = false
            var expectedThirdParty = false
            var expectedCheckThirdParty = false
            var expectedImportant = false
            var expectedDocumentWhitelist = false
            var expectedWebsocket = false
            var expectedUrlBlock = false
            var expectedCssExceptionRule = false
            var expectedJsInject = false
            var expectedMatchCase = false
            var expectedBlockPopups = false
            var expectedPermittedDomains: [String] = []
            var expectedRestrictedDomains: [String] = []
            var expectedPermittedContentTypes: [NetworkRule.ContentType] = [NetworkRule.ContentType.ALL]
            var expectedRestrictedContentTypes: [NetworkRule.ContentType] = []
            var expectedEnabledOptions: [NetworkRule.NetworkRuleOption] = []
            var expectedDisabledOptions: [NetworkRule.NetworkRuleOption] = []
            
        }
        
        let testCases: [TestCase] = [
            TestCase(
                // Normal rule without modifiers.
                ruleText: "||example.org^",
                expectedUrlRuleText: "||example.org^",
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?example\\.org([\\/:&\\?].*)?$"),
            TestCase(
                // Whitelist rule.
                ruleText: "@@||example.org^",
                expectedUrlRuleText: "||example.org^",
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?example\\.org([\\/:&\\?].*)?$",
                expectedWhiteList: true),
            TestCase(
                // $match-case rule.
                ruleText: "||example.org^$match-case",
                expectedUrlRuleText: "||example.org^",
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?example\\.org([\\/:&\\?].*)?$",
                expectedMatchCase: true),
            TestCase(
                // $popup rule.
                ruleText: "||example.org^$popup",
                expectedUrlRuleText: "||example.org^",
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?example\\.org([\\/:&\\?].*)?$",
                expectedBlockPopups: true,
                expectedPermittedContentTypes: [NetworkRule.ContentType.DOCUMENT]),
            TestCase(
                // $important rule.
                ruleText: "||example.org^$important",
                expectedUrlRuleText: "||example.org^",
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?example\\.org([\\/:&\\?].*)?$",
                expectedImportant: true),
            TestCase(
                // $document rule.
                ruleText: "@@||example.org^$document",
                expectedUrlRuleText: "||example.org^",
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?example\\.org([\\/:&\\?].*)?$",
                expectedWhiteList: true,
                expectedDocumentWhitelist: true,
                expectedPermittedContentTypes: [NetworkRule.ContentType.DOCUMENT],
                expectedEnabledOptions: [NetworkRule.NetworkRuleOption.Document]),
            TestCase(
                // $elemhide rule.
                ruleText: "@@||example.org^$elemhide",
                expectedUrlRuleText: "||example.org^",
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?example\\.org([\\/:&\\?].*)?$",
                expectedWhiteList: true,
                expectedCssExceptionRule: true,
                expectedPermittedContentTypes: [NetworkRule.ContentType.DOCUMENT],
                expectedEnabledOptions: [NetworkRule.NetworkRuleOption.Elemhide]),
            TestCase(
                // $jsinject rule.
                ruleText: "@@||example.org^$jsinject",
                expectedUrlRuleText: "||example.org^",
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?example\\.org([\\/:&\\?].*)?$",
                expectedWhiteList: true,
                expectedJsInject: true,
                expectedPermittedContentTypes: [NetworkRule.ContentType.DOCUMENT],
                expectedEnabledOptions: [NetworkRule.NetworkRuleOption.Jsinject]),
            TestCase(
                // $jsinject rule.
                ruleText: "@@||example.org^$urlblock",
                expectedUrlRuleText: "||example.org^",
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?example\\.org([\\/:&\\?].*)?$",
                expectedWhiteList: true,
                expectedUrlBlock: true,
                expectedPermittedContentTypes: [NetworkRule.ContentType.DOCUMENT],
                expectedEnabledOptions: [NetworkRule.NetworkRuleOption.Urlblock]),
            TestCase(
                // $jsinject rule.
                ruleText: "@@||example.org^$specifichide",
                expectedUrlRuleText: "||example.org^",
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?example\\.org([\\/:&\\?].*)?$",
                expectedWhiteList: true,
                expectedPermittedContentTypes: [NetworkRule.ContentType.DOCUMENT],
                expectedEnabledOptions: [NetworkRule.NetworkRuleOption.Specifichide]),
            TestCase(
                // Third-party rule.
                ruleText: "||example.org^$third-party",
                expectedUrlRuleText: "||example.org^",
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?example\\.org([\\/:&\\?].*)?$",
                expectedThirdParty: true,
                expectedCheckThirdParty: true),
            TestCase(
                // Third-party alias.
                ruleText: "||example.org^$3p",
                expectedUrlRuleText: "||example.org^",
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?example\\.org([\\/:&\\?].*)?$",
                expectedThirdParty: true,
                expectedCheckThirdParty: true),
            TestCase(
                // Third-party alias.
                ruleText: "||example.org^$~1p",
                expectedUrlRuleText: "||example.org^",
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?example\\.org([\\/:&\\?].*)?$",
                expectedThirdParty: true,
                expectedCheckThirdParty: true),
            TestCase(
                // Third-party alias.
                ruleText: "||example.org^$~first-party",
                expectedUrlRuleText: "||example.org^",
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?example\\.org([\\/:&\\?].*)?$",
                expectedThirdParty: true,
                expectedCheckThirdParty: true),
            TestCase(
                // $all for Safari is the same as a standard rule.
                ruleText: "||example.org^$all",
                expectedUrlRuleText: "||example.org^",
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?example\\.org([\\/:&\\?].*)?$"),
            TestCase(
                ruleText: "||example.org/this$is$path$image,font,media",
                expectedUrlRuleText: "||example.org/this$is$path",
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?example\\.org\\/this\\$is\\$path",
                expectedPermittedContentTypes: [NetworkRule.ContentType.IMAGE, NetworkRule.ContentType.FONT, NetworkRule.ContentType.MEDIA]),
            TestCase(
                // $websocket rule.
                ruleText: "||example.org^$websocket",
                expectedUrlRuleText: "||example.org^",
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?example\\.org([\\/:&\\?].*)?$",
                expectedWebsocket: true,
                expectedPermittedContentTypes: [NetworkRule.ContentType.WEBSOCKET]),
            TestCase(
                // $document for blocking page load.
                ruleText: "||example.org^$document",
                expectedUrlRuleText: "||example.org^",
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?example\\.org([\\/:&\\?].*)?$",
                expectedPermittedContentTypes: [NetworkRule.ContentType.DOCUMENT],
                expectedEnabledOptions: [NetworkRule.NetworkRuleOption.Document]),
            TestCase(
                ruleText: "||example.org\\$smth",
                expectedUrlRuleText: "||example.org\\$smth",
                // TODO(ameshkov): !!! Fix in SimpleRegex: this is a mistake, $ is escaped in the pattern, should've been "\\$smth""
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?example\\.org\\\\\\$smth"),
            TestCase(
                ruleText: "||example.org^$domain=example.org|~sub.example.org",
                expectedUrlRuleText: "||example.org^",
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?example\\.org([\\/:&\\?].*)?$",
                expectedPermittedDomains: ["example.org"],
                expectedRestrictedDomains: ["sub.example.org"]),
            TestCase(
                ruleText: "/regex/",
                expectedUrlRuleText: "/regex/",
                expectedUrlRegExpSource: "regex"),
            TestCase(
                ruleText: "@@/regex/",
                expectedUrlRuleText: "/regex/",
                expectedUrlRegExpSource: "regex",
                expectedWhiteList: true),
            TestCase(
                ruleText: "@@/regex/$third-party",
                expectedUrlRuleText: "/regex/",
                expectedUrlRegExpSource: "regex",
                expectedWhiteList: true,
                expectedThirdParty: true,
                expectedCheckThirdParty: true),
            TestCase(
                ruleText: "/example{/",
                expectedUrlRuleText: "/example{/",
                expectedUrlRegExpSource: "example{"),
            TestCase(
                ruleText: #"/^http:\/\/example\.org\/$/"#,
                expectedUrlRuleText: #"/^http:\/\/example\.org\/$/"#,
                expectedUrlRegExpSource: #"^http:\/\/example\.org\/$"#),
            TestCase(
                // Checking if correctly transformed to regex.
                ruleText: "/addyn|*|adtech",
                expectedUrlRuleText: "/addyn|*|adtech",
                expectedUrlRegExpSource: #"\/addyn\|.*\|adtech"#),
            TestCase(
                // Rule that matches all URLs.
                ruleText: "$image,frame,domain=a.com",
                expectedUrlRuleText: "",
                expectedUrlRegExpSource: nil,
                expectedPermittedDomains: ["a.com"],
                expectedPermittedContentTypes: [NetworkRule.ContentType.IMAGE, NetworkRule.ContentType.SUBDOCUMENT]),
            TestCase(
                // Testing egde case - the rule looks like it's a regex, but it has options.
                ruleText: "/example/$domain=test.com/",
                expectedUrlRuleText: "/example/",
                expectedUrlRegExpSource: "example",
                // Domain is invalid, but it doesn't break Safari.
                expectedPermittedDomains: ["test.com/"]),
            TestCase(
                // Testing if we can correctly convert domain in the rule to punycode.
                ruleText: "||почта.рф^",
                expectedUrlRuleText: "||xn--80a1acny.xn--p1ai^",
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?xn--80a1acny\\.xn--p1ai([\\/:&\\?].*)?$"),
            TestCase(
                // Testing if we can correctly convert domain in the $domain modifier to punycode.
                ruleText: "||example.org^$domain=почта.рф|example.net",
                expectedUrlRuleText: "||example.org^",
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?example\\.org([\\/:&\\?].*)?$",
                expectedPermittedDomains: ["xn--80a1acny.xn--p1ai", "example.net"]),
            TestCase(
                // Noop modifier
                ruleText: "||example.org^$domain=example.org,__,_,image,__________,script,_,___,_,_,_,_,__",
                expectedUrlRuleText: "||example.org^",
                expectedUrlRegExpSource: "^[htpsw]+:\\/\\/([a-z0-9-]+\\.)?example\\.org([\\/:&\\?].*)?$",
                expectedPermittedDomains: ["example.org"],
                expectedPermittedContentTypes: [NetworkRule.ContentType.IMAGE, NetworkRule.ContentType.SCRIPT]),
        ]
        
        

        for testCase in testCases {
            let result = try! NetworkRule(ruleText: testCase.ruleText)
            
            let msg = "Rule (\(testCase.ruleText)) does not match expected"

            XCTAssertEqual(result.urlRuleText, testCase.expectedUrlRuleText, msg)
            XCTAssertEqual(result.urlRegExpSource, testCase.expectedUrlRegExpSource, msg)
            XCTAssertEqual(result.isWhiteList, testCase.expectedWhiteList, msg)
            XCTAssertEqual(result.isThirdParty, testCase.expectedThirdParty, msg)
            XCTAssertEqual(result.isCheckThirdParty, testCase.expectedCheckThirdParty, msg)
            XCTAssertEqual(result.isImportant, testCase.expectedImportant, msg)
            XCTAssertEqual(result.isDocumentWhiteList, testCase.expectedDocumentWhitelist, msg)
            XCTAssertEqual(result.isWebSocket, testCase.expectedWebsocket, msg)
            XCTAssertEqual(result.isUrlBlock, testCase.expectedUrlBlock, msg)
            XCTAssertEqual(result.isJsInject, testCase.expectedJsInject, msg)
            XCTAssertEqual(result.isCssExceptionRule, testCase.expectedCssExceptionRule, msg)
            XCTAssertEqual(result.isMatchCase, testCase.expectedMatchCase, msg)
            XCTAssertEqual(result.isBlockPopups, testCase.expectedBlockPopups, msg)
            XCTAssertEqual(result.permittedDomains, testCase.expectedPermittedDomains, msg)
            XCTAssertEqual(result.restrictedDomains, testCase.expectedRestrictedDomains, msg)
            XCTAssertEqual(result.permittedContentType, testCase.expectedPermittedContentTypes, msg)
            XCTAssertEqual(result.restrictedContentType, testCase.expectedRestrictedContentTypes, msg)
            XCTAssertEqual(result.enabledOptions, testCase.expectedEnabledOptions, msg)
            XCTAssertEqual(result.disabledOptions, testCase.expectedDisabledOptions, msg)
        }
    }
    
    // TODO(ameshkov): !!! Rework when SafariVersion tests are introduced.
    func testPingModifier() {
        var rule = "||example.com^$ping"
        XCTAssertThrowsError(try NetworkRule(ruleText: rule))

        rule = "||example.com^$~ping"
        XCTAssertThrowsError(try NetworkRule(ruleText: rule))
    }
    
    func testNetworkRuleWithInvalidRules() {
        // $replace is not supported by Safari.
        XCTAssertThrowsError(try NetworkRule(ruleText: "/example/$replace=/test/test2/"))
        // $elemhide is only allowed for whitelist rules.
        XCTAssertThrowsError(try NetworkRule(ruleText: "||example.org^$elemhide"))
        // $jsinject is only allowed for whitelist rules.
        XCTAssertThrowsError(try NetworkRule(ruleText: "||example.org^$jsinject"))
        // $specifichide is only allowed for whitelist rules.
        XCTAssertThrowsError(try NetworkRule(ruleText: "||example.org^$specifichide"))
        // $urlblock is only allowed for whitelist rules.
        XCTAssertThrowsError(try NetworkRule(ruleText: "||example.org^$urlblock"))
        // $csp is not supported by Safari.
        XCTAssertThrowsError(try NetworkRule(ruleText: "||example.org^$csp=script-src self"))
        // $redirect-rule is not supported by Safari.
        XCTAssertThrowsError(try NetworkRule(ruleText: "||example.org^$redirect-rule=noopjs"))
        // $redirect is not supported by Safari.
        XCTAssertThrowsError(try NetworkRule(ruleText: "||example.org^$redirect=noopjs"))
        // $empty is not supported by Safari.
        XCTAssertThrowsError(try NetworkRule(ruleText: "||example.org^$empty"))
        // $mp4 is not supported by Safari.
        XCTAssertThrowsError(try NetworkRule(ruleText: "||example.org^$mp4"))
        // $document cannot have a value.
        XCTAssertThrowsError(try NetworkRule(ruleText: "||example.org^$doc=test"))
        // $domain must have a valid value.
        XCTAssertThrowsError(try NetworkRule(ruleText: "||example.org^$domain="))
        // $domain must have a valid value.
        XCTAssertThrowsError(try NetworkRule(ruleText: "||example.org^$domain=~"))
        // $domain must have a valid value.
        XCTAssertThrowsError(try NetworkRule(ruleText: "||example.org^$domain=e"))
        // $domain must have a valid value.
        XCTAssertThrowsError(try NetworkRule(ruleText: "||example.org^$domain=~e"))
        // $domain with regexes are not supported.
        XCTAssertThrowsError(try NetworkRule(ruleText: "||example.org^$domain=/example.org/"))
        // $domain with regexes are not supported.
        XCTAssertThrowsError(try NetworkRule(ruleText: "||example.org^$domain=example.org|/test.com/"))
        // Empty regular expressions make no sense.
        XCTAssertThrowsError(try NetworkRule(ruleText: "//$domain=example.com"))
        // Non-ASCII symbols outside the domain are not supported and not encoded.
        XCTAssertThrowsError(try NetworkRule(ruleText: "||example.org/почта"))
    }
    
    func testExtractDomain() {
        let testPatterns: [(pattern: String, expectedDomain: String, expectedPatternMatchesPath: Bool)] = [
            ("", "", false),
            ("/", "", false),
            ("@@", "", false),
            ("@@^", "", false),
            ("@@/", "", false),
            ("example", "example", false),
            ("example.com", "example.com", false),
            ("||example.com", "example.com", false),
            ("||example.com/path", "example.com", true),
            ("||invalid/path", "invalid", true),
            ("http://example.org$", "example.org", false),
            ("https://example.org^someother", "example.org", true),
        ]
        
        for testPattern in testPatterns {
            let result = NetworkRuleParser.extractDomain(pattern: testPattern.pattern)
            XCTAssertEqual(result.domain, testPattern.expectedDomain, "Pattern \(testPattern.pattern): expected domain \(testPattern.expectedDomain), but got \(result.domain)")
            XCTAssertEqual(result.patternMatchesPath, testPattern.expectedPatternMatchesPath, "Pattern \(testPattern.pattern): expected patternMatchesPath \(testPattern.expectedPatternMatchesPath), but got \(result.patternMatchesPath)")
        }
    }
    
    func testExtractDomainAndValidate() {
        let testPatterns: [(pattern: String, expectedDomain: String, expectedPatternMatchesPath: Bool)] = [
            ("", "", false),
            ("/", "", false),
            ("@@", "", false),
            ("@@^", "", false),
            ("@@/", "", false),
            ("example", "", false),
            ("example.com", "example.com", false),
            ("||example.com", "example.com", false),
            ("||example.com/path", "example.com", true),
            ("||invalid/path", "", false),
            ("http://example.org$", "example.org", false),
            ("https://example.org^someother", "example.org", true),
        ]

        for testPattern in testPatterns {
            let result = NetworkRuleParser.extractDomainAndValidate(pattern: testPattern.pattern)
            XCTAssertEqual(result.domain, testPattern.expectedDomain, "Pattern \(testPattern.pattern): expected domain \(testPattern.expectedDomain), but got \(result.domain)")
            XCTAssertEqual(result.patternMatchesPath, testPattern.expectedPatternMatchesPath, "Pattern \(testPattern.pattern): expected patternMatchesPath \(testPattern.expectedPatternMatchesPath), but got \(result.patternMatchesPath)")
        }
    }
    
    func testNegatesBadfilter() {
        let testRules: [(rule: String, badfilter: String, expected: Bool)] = [
            ("||example.org^", "||example.org^$badfilter", true),
            ("||example.org", "||example.org^$badfilter", false),
            ("||example.org^$script", "||example.org^$badfilter", false),
            ("||example.org^$script", "||example.org^$script,badfilter", true),
            ("||example.org^$script,xhr", "||example.org^$script,badfilter", false),
            ("||example.org^$script,xhr", "||example.org^$script,xhr,badfilter", true),
            ("||example.org^", "||example.org^$badfilter,domain=example.com", false),
            ("||example.org^$domain=~example.com", "||example.org^$badfilter", false),
            ("||example.org^$domain=~example.com", "||example.org^$domain=~example.com,badfilter", true),
            ("||example.org^$domain=example.com", "||example.org^$badfilter,domain=example.com", true),
            ("||example.org^$domain=example.com|example.net", "||example.org^$badfilter,domain=example.org|example.com", true),
        ]
        
        for (rule, badfilter, expected) in testRules {
            let networkRule = try! NetworkRule(ruleText: rule)
            let badfilterRule = try! NetworkRule(ruleText: badfilter)
            XCTAssertEqual(badfilterRule.negatesBadfilter(specifiedRule: networkRule), expected, "Rule \(badfilter) expected to \(expected ? "negate" : "not negate") \(rule)")
        }
    }
}
