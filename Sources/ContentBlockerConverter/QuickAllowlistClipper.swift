import Foundation

/**
 * Provides methods to manage allowlist and inverted allowlist rules without conversion
 */
public protocol QuickAllowlistClipperProtocol {
    // Replaces rule in conversion result with provided rule
    func replace(rule: String, with newRule: String, in conversionResult: ConversionResult) throws -> ConversionResult
    
    // Public method to create allowlist rule for provided domain and append it to conversion result
    func addAllowlistRule(by domain: String, to conversionResult: ConversionResult) throws -> ConversionResult
    
    // Public method to create inverted allowlist rule for provided domain and append it to conversion result
    func addInvertedAllowlistRule(by domain: String, to conversionResult: ConversionResult) throws -> ConversionResult
    
    // Public method to create allowlist rule for provided domain and remove it from provided conversion result
    func removeAllowlistRule(by domain: String, from conversionResult: ConversionResult) throws -> ConversionResult
    
    // Public method to create inverted allowlist rule for provided domain and remove it from provided Ωconversion result
    func removeInvertedAllowlistRule(by domain: String, from conversionResult: ConversionResult) throws -> ConversionResult
    
    // Public method to check if allowlist rules contain allowlist rule for provided domain
    func allowlistContains(domain: String, _ allowlistRules: [String]) -> Bool
    
    // Public method to check if inverted allowlist rules contain inverted allowlist rule for provided domain
    func invertedAllowlistContains(domain: String, _ invertedAllowlistRules: [String]) -> Bool
    
    // Public method to check if provided rule is associated with the domain
    func userRuleIsAssociated(with domain: String, _ userRule: String) -> Bool
}

/**
 * Special service for managing allowlist rules:
 * quickly add/remove allowlist rules without filters recompilation
 */
public class QuickAllowlistClipper: QuickAllowlistClipperProtocol {
    public init() {}
    
    let converter = ContentBlockerConverter();

    /**
     * Converts provided rule to json format and returns as string
     */
    func convertRuleToJsonString(ruleText: String) -> String {
        let conversionResult = converter.convertArray(rules: [ruleText])
        let convertedRule = conversionResult.converted.dropFirst(1).dropLast(1);
        return String(convertedRule);
    }

    /**
     * Appends provided rule to conversion result
     */
    func add(rule: String, to conversionResult: ConversionResult) throws -> ConversionResult {
        let convertedRule = convertRuleToJsonString(ruleText: rule);

        if conversionResult.converted.contains(convertedRule) {
            throw QuickAllowlistClipperError.errorAddingRule;
        }

        var result = conversionResult;
        result.converted = String(result.converted.dropLast(1));
        result.converted += ",\(convertedRule)]"
        result.convertedCount += 1;
        result.totalConvertedCount += 1;

        return result;
    }

    /**
     * Removes provided rule from conversion result
     */
    func remove(rule: String, from conversionResult: ConversionResult) throws -> ConversionResult {
        let convertedRule = convertRuleToJsonString(ruleText: rule);

        if !conversionResult.converted.contains(convertedRule) {
            throw QuickAllowlistClipperError.noRuleInConversionResult;
        }

        // amount of rules to remove in conversion result
        let delta = conversionResult.converted.components(separatedBy: convertedRule).count - 1;

        var result = conversionResult;
        result.converted = result.converted.replacingOccurrences(of: convertedRule, with: "");

        // remove redundant commas
        if result.converted.hasPrefix("[,{") {
            result.converted = result.converted.replacingOccurrences(of: "[,{", with: "[{");
        }
        if result.converted.hasSuffix("},]") {
            result.converted = result.converted.replacingOccurrences(of: "},]", with: "}]");
        }
        while result.converted.contains(",,") {
            result.converted = result.converted.replacingOccurrences(of: ",,", with: ",");
        }
        // handle empty result
        if result.converted == "[]" {
            return ConversionResult.createEmptyResult();
        }

        result.convertedCount -= delta;
        result.totalConvertedCount -= delta;

        return result;
    }

    /**
     * Replaces rule in conversion result with provided rule
     */
    public func replace(rule: String, with newRule: String, in conversionResult: ConversionResult) throws -> ConversionResult {
        var result = conversionResult;
        let ruleJsonString = convertRuleToJsonString(ruleText: rule);

        if !result.converted.contains(ruleJsonString) {
            throw QuickAllowlistClipperError.noRuleInConversionResult;
        }

        let newRuleJsonString = convertRuleToJsonString(ruleText: newRule);

        result.converted = result.converted.replacingOccurrences(of: ruleJsonString, with: newRuleJsonString);
        return result;
    }

    /**
     * Appends allowlist rule for provided domain to conversion result
     */
    public func addAllowlistRule(by domain: String, to conversionResult: ConversionResult) throws -> ConversionResult {
        let allowlistRule = ContentBlockerConverter.createAllowlistRule(by: domain);
        return try add(rule: allowlistRule, to: conversionResult);
    }

    /**
     * Appends inverted allowlist rule for provided domain to conversion result
     */
    public func addInvertedAllowlistRule(by domain: String, to conversionResult: ConversionResult) throws -> ConversionResult {
        let invertedAllowlistRule = ContentBlockerConverter.createInvertedAllowlistRule(by: domain);
        return try add(rule: invertedAllowlistRule, to: conversionResult);
    }

    /**
     * Removes allowlist rule for provided domain from conversion result
     */
    public func removeAllowlistRule(by domain: String, from conversionResult: ConversionResult) throws -> ConversionResult {
        let allowlistRule = ContentBlockerConverter.createAllowlistRule(by: domain);
        return try remove(rule: allowlistRule, from: conversionResult);
    }

    /**
     * Removes inverted allowlist rule for provided domain from conversion result
     */
    public func removeInvertedAllowlistRule(by domain: String, from conversionResult: ConversionResult) throws -> ConversionResult {
        let invertedAllowlistRule = ContentBlockerConverter.createInvertedAllowlistRule(by: domain);
        return try remove(rule: invertedAllowlistRule, from: conversionResult);
    }
    
    /**
     * Checks if allowlist rules contain allowlist rule for provided domain
     */
    public func allowlistContains(domain: String, _ allowlistRules: [String]) -> Bool {
        let allowlistRuleToFind = ContentBlockerConverter.createAllowlistRule(by: domain)
        let allowlistRuleWithSeparatorToFind = ContentBlockerConverter.createAllowlistRule(by: domain + "^")
        return allowlistRules.contains { $0 == allowlistRuleToFind || $0 == allowlistRuleWithSeparatorToFind }
    }
    
    /**
     * Checks if inverted allowlist rules contain inverted allowlist rule for provided domain
     */
    public func invertedAllowlistContains(domain: String, _ invertedAllowlistRules: [String]) -> Bool {
        let invertedAllowlistRuleToFind = ContentBlockerConverter.createInvertedAllowlistRule(by: domain)
        return invertedAllowlistRules.contains { $0 == invertedAllowlistRuleToFind }
    }
    
    /**
     * Parses domains from provided rule
     */
    func parseRuleDomains(ruleText: String) -> [String] {
        do {
            let rule = try RuleFactory.createRule(ruleText: ruleText as NSString)
            if rule == nil {
                return []
            }
            
            var ruleDomains = rule!.permittedDomains + rule!.restrictedDomains
            
            if !RuleFactory.isCosmetic(ruleText: ruleText as NSString) {
                let ruleDomain = (rule! as! NetworkRule).parseRuleDomain()?.domain
                if (ruleDomain != nil) {
                    ruleDomains += [String(ruleDomain!)]
                }
            }
            return ruleDomains;

        } catch {
            return []
        }
    }
    
    /**
     * Checks if provided rule is associated with the domain
     */
    public func userRuleIsAssociated(with domain: String, _ userRule: String) -> Bool {
        let ruleDomains = parseRuleDomains(ruleText: userRule)
        return ruleDomains.contains{ $0 == domain }
    }
}

public enum QuickAllowlistClipperError: Error, CustomDebugStringConvertible {
    case errorConvertingRule
    case noRuleInConversionResult
    case errorAddingRule

    public var debugDescription: String {
        switch self {
            case .errorConvertingRule: return "A rule conversion error has occurred"
            case .noRuleInConversionResult: return "Conversion result doesn't contain provided rule"
            case .errorAddingRule: return "The provided rule is already in conversion result"
        }
    }
}
