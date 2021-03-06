import Foundation

/// A Nimble matcher that succeeds when the actual value is the same instance
/// as the expected instance.
public func beIdenticalTo(_ expected: Any?) -> Predicate<Any> {
    return Predicate.define { actualExpression in
        #if os(Linux)
            #if swift(>=4.0)
                #if !swift(>=4.1.50)
                    let actual = try actualExpression.evaluate() as? AnyObject
                #else
                    let actual = try actualExpression.evaluate() as AnyObject?
                #endif
            #else
                #if !swift(>=3.4)
                    let actual = try actualExpression.evaluate() as? AnyObject
                #else
                    let actual = try actualExpression.evaluate() as AnyObject?
                #endif
            #endif
        #else
            let actual = try actualExpression.evaluate() as AnyObject?
        #endif

        let bool: Bool
        #if os(Linux)
            #if swift(>=4.0)
                #if !swift(>=4.1.50)
                    bool = actual === (expected as? AnyObject) && actual !== nil
                #else
                    bool = actual === (expected as AnyObject?) && actual !== nil
                #endif
            #else
                #if !swift(>=3.4)
                    bool = actual === (expected as? AnyObject) && actual !== nil
                #else
                    bool = actual === (expected as AnyObject?) && actual !== nil
                #endif
            #endif
        #else
            bool = actual === (expected as AnyObject?) && actual !== nil
        #endif
        return PredicateResult(
            bool: bool,
            message: .expectedCustomValueTo(
                "be identical to \(identityAsString(expected))",
                "\(identityAsString(actual))"
            )
        )
    }
}

public func === (lhs: Expectation<Any>, rhs: Any?) {
    lhs.to(beIdenticalTo(rhs))
}
public func !== (lhs: Expectation<Any>, rhs: Any?) {
    lhs.toNot(beIdenticalTo(rhs))
}

/// A Nimble matcher that succeeds when the actual value is the same instance
/// as the expected instance.
///
/// Alias for "beIdenticalTo".
public func be(_ expected: Any?) -> Predicate<Any> {
    return beIdenticalTo(expected)
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
extension NMBObjCMatcher {
    @objc public class func beIdenticalToMatcher(_ expected: NSObject?) -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            let aExpr = actualExpression.cast { $0 as Any? }
            return try beIdenticalTo(expected).matches(aExpr, failureMessage: failureMessage)
        }
    }
}
#endif
