import Foundation

import XCTest
@testable import ContentBlockerConverter

final class BlockerEntryFactoryTests: XCTestCase {
    func testConvertNetworkRule() {
        let converter = BlockerEntryFactory(advancedBlockingEnabled: false);

        let rule = NetworkRule();
        rule.ruleText = "||example.com/path$domain=test.com";
        rule.permittedDomains = ["test.com"];

        let result = converter.createBlockerEntry(rule: rule);
        XCTAssertNotNil(result);
        XCTAssertEqual(result!.trigger.urlFilter, "^[htpsw]+:\\/\\/");
        XCTAssertEqual(result!.trigger.ifDomain![0], "test.com");
        XCTAssertEqual(result!.trigger.unlessDomain, nil);
        XCTAssertEqual(result!.trigger.shortcut, nil);
        XCTAssertEqual(result!.trigger.regex, nil);

        XCTAssertEqual(result!.action.type, "block");
        XCTAssertEqual(result!.action.selector, nil);
        XCTAssertEqual(result!.action.css, nil);
        XCTAssertEqual(result!.action.script, nil);
        XCTAssertEqual(result!.action.scriptlet, nil);
        XCTAssertEqual(result!.action.scriptletParam, nil);
    }
    
    func testConvertNetworkRuleRegExp() {
        let converter = BlockerEntryFactory(advancedBlockingEnabled: false);

        let rule = NetworkRule();
        rule.urlRuleText = "/regex/$script";
        rule.urlRegExpSource = "regex";

        let result = converter.createBlockerEntry(rule: rule);
        XCTAssertNotNil(result);
        XCTAssertEqual(result!.trigger.urlFilter, "regex");
        XCTAssertEqual(result!.trigger.ifDomain, nil);
        XCTAssertEqual(result!.trigger.unlessDomain, nil);
        XCTAssertEqual(result!.trigger.shortcut, nil);
        XCTAssertEqual(result!.trigger.regex, nil);

        XCTAssertEqual(result!.action.type, "block");
        XCTAssertEqual(result!.action.selector, nil);
        XCTAssertEqual(result!.action.css, nil);
        XCTAssertEqual(result!.action.script, nil);
        XCTAssertEqual(result!.action.scriptlet, nil);
        XCTAssertEqual(result!.action.scriptletParam, nil);
    }
    
    func testConvertNetworkRuleWhitelist() {
        let converter = BlockerEntryFactory(advancedBlockingEnabled: false);

        let rule = NetworkRule();
        rule.isWhiteList = true;
        rule.isDocumentWhiteList = true;
        rule.ruleText = "@@||example.com^$document";
        rule.urlRuleText = "||example.com^$document";

        var result = converter.createBlockerEntry(rule: rule);
        XCTAssertNotNil(result);
        XCTAssertEqual(result!.trigger.urlFilter, ".*");
        XCTAssertEqual(result!.trigger.ifDomain![0], "example.com");
        XCTAssertEqual(result!.trigger.unlessDomain, nil);
        
        rule.ruleText = "@@||example.com$document";
        rule.urlRuleText = "||example.com$document";

        result = converter.createBlockerEntry(rule: rule);
        XCTAssertNotNil(result);
        XCTAssertEqual(result!.trigger.urlFilter, "^[htpsw]+:\\/\\/");
        XCTAssertEqual(result!.trigger.ifDomain![0], "example.com");
        XCTAssertEqual(result!.trigger.unlessDomain, nil);
    }
    
    func testConvertScriptRule() {
        let converter = BlockerEntryFactory(advancedBlockingEnabled: true);

        let rule = CosmeticRule();
        rule.isScript = true;
        rule.script = "test script";
        rule.permittedDomains = ["test_domain_one", "test_domain_two"];

        let result = converter.createBlockerEntry(rule: rule);
        XCTAssertNotNil(result);
        XCTAssertEqual(result!.trigger.urlFilter, ".*");
        XCTAssertEqual(result!.trigger.ifDomain!.count, 2);
        XCTAssertEqual(result!.trigger.unlessDomain, nil);
        XCTAssertEqual(result!.trigger.shortcut, nil);
        XCTAssertEqual(result!.trigger.regex, nil);

        XCTAssertEqual(result!.action.type, "script");
        XCTAssertEqual(result!.action.selector, nil);
        XCTAssertEqual(result!.action.css, nil);
        XCTAssertEqual(result!.action.script, "test script");
        XCTAssertEqual(result!.action.scriptlet, nil);
        XCTAssertEqual(result!.action.scriptletParam, nil);
    }
    
    func testConvertScriptRuleWhitelist() {
        let converter = BlockerEntryFactory(advancedBlockingEnabled: true);

        let rule = CosmeticRule();
        rule.isScript = true;
        rule.script = "test script";
        rule.permittedDomains = ["test_domain_one", "test_domain_two"];
        rule.isWhiteList = true;

        let result = converter.createBlockerEntry(rule: rule);
        XCTAssertNotNil(result);
        XCTAssertEqual(result!.trigger.urlFilter, ".*");
        XCTAssertEqual(result!.trigger.ifDomain!.count, 2);
        XCTAssertEqual(result!.trigger.unlessDomain, nil);
        XCTAssertEqual(result!.trigger.shortcut, nil);
        XCTAssertEqual(result!.trigger.regex, nil);

        XCTAssertEqual(result!.action.type, "ignore-previous-rules");
        XCTAssertEqual(result!.action.selector, nil);
        XCTAssertEqual(result!.action.css, nil);
        XCTAssertEqual(result!.action.script, "test script");
        XCTAssertEqual(result!.action.scriptlet, nil);
        XCTAssertEqual(result!.action.scriptletParam, nil);
    }
    
    func testConvertScriptletRule() {
        let converter = BlockerEntryFactory(advancedBlockingEnabled: true);

        let rule = CosmeticRule();
        rule.isScriptlet = true;
        rule.scriptlet = "test scriptlet";
        rule.scriptletParam = "test scriptlet param";
        rule.restrictedDomains = ["test_domain_one", "test_domain_two"];

        let result = converter.createBlockerEntry(rule: rule);
        XCTAssertNotNil(result);
        XCTAssertEqual(result!.trigger.urlFilter, ".*");
        XCTAssertEqual(result!.trigger.ifDomain, nil);
        XCTAssertEqual(result!.trigger.unlessDomain!.count, 2);
        XCTAssertEqual(result!.trigger.shortcut, nil);
        XCTAssertEqual(result!.trigger.regex, nil);

        XCTAssertEqual(result!.action.type, "scriptlet");
        XCTAssertEqual(result!.action.selector, nil);
        XCTAssertEqual(result!.action.css, nil);
        XCTAssertEqual(result!.action.script, nil);
        XCTAssertEqual(result!.action.scriptlet, "test scriptlet");
        XCTAssertEqual(result!.action.scriptletParam, "test scriptlet param");
    }
    
    func testConvertScriptletRuleWhitelist() {
        let converter = BlockerEntryFactory(advancedBlockingEnabled: true);

        let rule = CosmeticRule();
        rule.isScriptlet = true;
        rule.scriptlet = "test scriptlet";
        rule.scriptletParam = "test scriptlet param";
        rule.restrictedDomains = ["test_domain_one", "test_domain_two"];
        rule.isWhiteList = true;

        let result = converter.createBlockerEntry(rule: rule);
        XCTAssertNotNil(result);
        XCTAssertEqual(result!.trigger.urlFilter, ".*");
        XCTAssertEqual(result!.trigger.ifDomain, nil);
        XCTAssertEqual(result!.trigger.unlessDomain!.count, 2);
        XCTAssertEqual(result!.trigger.shortcut, nil);
        XCTAssertEqual(result!.trigger.regex, nil);

        XCTAssertEqual(result!.action.type, "ignore-previous-rules");
        XCTAssertEqual(result!.action.selector, nil);
        XCTAssertEqual(result!.action.css, nil);
        XCTAssertEqual(result!.action.script, nil);
        XCTAssertEqual(result!.action.scriptlet, "test scriptlet");
        XCTAssertEqual(result!.action.scriptletParam, "test scriptlet param");
    }
    
    func testConvertCssRule() {
        let converter = BlockerEntryFactory(advancedBlockingEnabled: true);

        let rule = CosmeticRule();
        rule.cssSelector = "test_css_selector";
        rule.restrictedDomains = ["test_domain_one", "test_domain_two"];

        let result = converter.createBlockerEntry(rule: rule);
        XCTAssertNotNil(result);
        XCTAssertEqual(result!.trigger.urlFilter, ".*");
        XCTAssertEqual(result!.trigger.ifDomain, nil);
        XCTAssertEqual(result!.trigger.unlessDomain!.count, 2);
        XCTAssertEqual(result!.trigger.shortcut, nil);
        XCTAssertEqual(result!.trigger.regex, nil);

        XCTAssertEqual(result!.action.type, "css-display-none");
        XCTAssertEqual(result!.action.selector, "test_css_selector");
        XCTAssertEqual(result!.action.css, nil);
    }
    
    func testConvertCssRuleExtendedCss() {
        let converter = BlockerEntryFactory(advancedBlockingEnabled: true);

        let rule = CosmeticRule();
        rule.isExtendedCss = true;
        rule.cssSelector = "test_css_selector";
        rule.restrictedDomains = ["test_domain_one", "test_domain_two"];

        let result = converter.createBlockerEntry(rule: rule);
        XCTAssertNotNil(result);
        XCTAssertEqual(result!.trigger.urlFilter, ".*");
        XCTAssertEqual(result!.trigger.ifDomain, nil);
        XCTAssertEqual(result!.trigger.unlessDomain!.count, 2);
        XCTAssertEqual(result!.trigger.shortcut, nil);
        XCTAssertEqual(result!.trigger.regex, nil);

        XCTAssertEqual(result!.action.type, "css");
        XCTAssertEqual(result!.action.selector, nil);
        XCTAssertEqual(result!.action.css, "test_css_selector");
    }
    
    func testConvertInvalidCssRule() {
        let converter = BlockerEntryFactory(advancedBlockingEnabled: true);

        let rule = CosmeticRule();
        rule.isExtendedCss = true;
        rule.cssSelector = "some url(test)";
        rule.restrictedDomains = ["test_domain_one", "test_domain_two"];

        let result = converter.createBlockerEntry(rule: rule);
        XCTAssertNil(result);
    }
    
    func testConvertInvalidRegexNetworkRule() {
        let converter = BlockerEntryFactory(advancedBlockingEnabled: false);

        let rule = NetworkRule();
        rule.urlRuleText = "/regex/$script";
        
        rule.urlRegExpSource = "regex{0,9}";
        var result = converter.createBlockerEntry(rule: rule);
        XCTAssertNil(result);
        
        rule.urlRegExpSource = "regex|test";
        result = converter.createBlockerEntry(rule: rule);
        XCTAssertNil(result);
        
        rule.urlRegExpSource = "test(?!test)";
        result = converter.createBlockerEntry(rule: rule);
        XCTAssertNil(result);
        
        rule.urlRegExpSource = "test\\b";
        result = converter.createBlockerEntry(rule: rule);
        XCTAssertNil(result);
    }
    
    func testConvertInvalidNetworkRule() {
        let converter = BlockerEntryFactory(advancedBlockingEnabled: true);

        let rule = createTestNetworkRule();
        
        rule.permittedContentType = [NetworkRule.ContentType.SUBDOCUMENT]
        rule.isCheckThirdParty = true;
        rule.isThirdParty = true;
        let result = converter.createBlockerEntry(rule: rule);
        XCTAssertNil(result);
    }
    
    func testTldDomains() {
        let converter = BlockerEntryFactory(advancedBlockingEnabled: true);
        let rule = createTestRule();
        
        rule.permittedDomains = [".*"];

        let result = converter.createBlockerEntry(rule: rule);
        XCTAssertNotNil(result);
        XCTAssertTrue(result!.trigger.ifDomain!.count >= 100);
    }
    
    func testDomainsRestrictions() {
        let converter = BlockerEntryFactory(advancedBlockingEnabled: true);
        let rule = createTestRule();
        
        rule.permittedDomains = ["permitted"];
        rule.restrictedDomains = ["restricted"];

        let result = converter.createBlockerEntry(rule: rule);
        XCTAssertNil(result);
    }
    
    func testThirdParty() {
        let converter = BlockerEntryFactory(advancedBlockingEnabled: false);
        let rule = createTestNetworkRule();
        
        rule.isCheckThirdParty = false;
        rule.isThirdParty = true;

        var result = converter.createBlockerEntry(rule: rule);
        XCTAssertNil(result!.trigger.loadType);
        
        rule.isCheckThirdParty = true;
        rule.isThirdParty = true;
        result = converter.createBlockerEntry(rule: rule);
        XCTAssertEqual(result!.trigger.loadType!.count, 1);
        XCTAssertEqual(result!.trigger.loadType![0], "third-party");
        
        rule.isCheckThirdParty = true;
        rule.isThirdParty = false;
        result = converter.createBlockerEntry(rule: rule);
        XCTAssertEqual(result!.trigger.loadType!.count, 1);
        XCTAssertEqual(result!.trigger.loadType![0], "first-party");
    }
    
    func testMatchCase() {
        let converter = BlockerEntryFactory(advancedBlockingEnabled: false);
        let rule = createTestNetworkRule();

        var result = converter.createBlockerEntry(rule: rule);
        XCTAssertNil(result!.trigger.caseSensitive);
        
        rule.isMatchCase = false;
        result = converter.createBlockerEntry(rule: rule);
        XCTAssertNil(result!.trigger.caseSensitive);
        
        rule.isMatchCase = true;
        result = converter.createBlockerEntry(rule: rule);
        XCTAssertEqual(result!.trigger.caseSensitive, true);
    }

    func testResourceTypes() {
        let converter = BlockerEntryFactory(advancedBlockingEnabled: false);
        let rule = createTestNetworkRule();

        var result = converter.createBlockerEntry(rule: rule);
        XCTAssertNil(result!.trigger.resourceType);

        rule.permittedContentType = [NetworkRule.ContentType.ALL];
        rule.restrictedContentType = [];
        result = converter.createBlockerEntry(rule: rule);
        XCTAssertNil(result!.trigger.resourceType);

        rule.permittedContentType = [NetworkRule.ContentType.IMAGE];
        rule.restrictedContentType = [];
        result = converter.createBlockerEntry(rule: rule);
        XCTAssertEqual(result!.trigger.resourceType, ["image"]);
        
        rule.permittedContentType = [NetworkRule.ContentType.IMAGE, NetworkRule.ContentType.FONT];
        rule.restrictedContentType = [];
        result = converter.createBlockerEntry(rule: rule);
        XCTAssertEqual(result!.trigger.resourceType, ["image", "font"]);
        
        rule.permittedContentType = [NetworkRule.ContentType.IMAGE, NetworkRule.ContentType.FONT];
        rule.restrictedContentType = [NetworkRule.ContentType.FONT];
        result = converter.createBlockerEntry(rule: rule);
        XCTAssertEqual(result!.trigger.resourceType, ["image"]);
    }
    
    func testInvalidResourceTypes() {
        let converter = BlockerEntryFactory(advancedBlockingEnabled: false);
        let rule = createTestNetworkRule();

        rule.permittedContentType = [NetworkRule.ContentType.OBJECT];
        var result = converter.createBlockerEntry(rule: rule);
        XCTAssertNil(result);
        
        rule.permittedContentType = [NetworkRule.ContentType.OBJECT_SUBREQUEST];
        result = converter.createBlockerEntry(rule: rule);
        XCTAssertNil(result);
        
        rule.permittedContentType = [NetworkRule.ContentType.WEBRTC];
        result = converter.createBlockerEntry(rule: rule);
        XCTAssertNil(result);
        
        rule.permittedContentType = [NetworkRule.ContentType.IMAGE];
        rule.isReplace = true;
        result = converter.createBlockerEntry(rule: rule);
        XCTAssertNil(result);
    }
    
    private func createTestRule() -> Rule {
        let rule = CosmeticRule();
        
        rule.isScript = true;
        rule.script = "test script";
        
        return rule;
    }
    
    private func createTestNetworkRule() -> NetworkRule {
        let rule = NetworkRule();
        
        return rule;
    }
    
    static var allTests = [
        ("testConvertNetworkRule", testConvertNetworkRule),
        ("testConvertNetworkRuleRegExp", testConvertNetworkRuleRegExp),
        ("testConvertNetworkRuleWhitelist", testConvertNetworkRuleWhitelist),
        ("testConvertScriptRule", testConvertScriptRule),
        ("testConvertScriptRuleWhitelist", testConvertScriptRuleWhitelist),
        ("testConvertScriptletRule", testConvertScriptletRule),
        ("testConvertScriptletRuleWhitelist", testConvertScriptletRuleWhitelist),
        ("testConvertCssRule", testConvertCssRule),
        ("testConvertCssRuleExtendedCss", testConvertCssRuleExtendedCss),
        ("testConvertInvalidCssRule", testConvertInvalidCssRule),
        ("testConvertInvalidNetworkRule", testConvertInvalidNetworkRule),
        ("testConvertInvalidRegexNetworkRule", testConvertInvalidRegexNetworkRule),
        ("testTldDomains", testTldDomains),
        ("testDomainsRestrictions", testDomainsRestrictions),
        ("testThirdParty", testThirdParty),
        ("testMatchCase", testMatchCase),
        ("testResourceTypes", testResourceTypes),
    ]
}
