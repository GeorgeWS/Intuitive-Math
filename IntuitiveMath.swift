//
//  Created by George Woodliff-Stanley on 12/31/15.
//  Copyright (c) 2015 George Woodliff-Stanley.
//

import Darwin

/// Create a random number generator whose outputs are within a given range.
func random(var from from: Double, var to: Double) -> Void -> Double {
	if to < from { swap(&to, &from) }
	return { _ in
		(((Double(arc4random())
			% (Double(UInt32.max) + 1))
			/ Double(UInt32.max))
			* (to - from))
			+ from
	}
}

/// Transform a mathematical function `f` into a new mathematical function using
/// standard transformation parameters (`a`, `b`, `d`, and `h`).
///
/// As few as none and as many as all of the parameters may be specified. At
/// least one must be specified for the transformation to have any effect; the
/// default parameters leave `f` untransformed.
///
/// - parameters:
///		- f: function to transform
///		- a: vertical scale factor
///		- b: horizontal scale factor (behavior varies between functions)
///		- h: horizontal shift
///		- d: vertical shift
///
func transform(f: (Double -> Double), a: Double = 1, b: Double = 1, h: Double = 0, d: Double = 0) -> Double -> Double {
	return { x in
		a * f(b * (x - h)) + d
	}
}

/// Returns the number a given percentage from one number to another.
///
///	- parameter percentage: The percentage specifying where in the given range
///		the desired value is located.
///
func numberScaledByPercentage(percentage: Double, from: Double, to: Double) -> Double {
	return from + percentage * (to - from)
}

/// A structure encapsulating the parameters and application of a hyperbolic
/// tangent curve, useful for smooth animation or difficulty curves. An
/// untransformed hyperbolic tangent curve looks like a smooth, continuously
/// increasing "S" with a horizontal asymptote on each end.
///
/// An `IntuitiveCurve` allows you to specify such a curve in terms of its
/// "apparent" start and end points, where the function appears to depart from
/// its two horizontal asymptotes. These points are defined as the locations of
/// the function values at a customizable percentage (defaulting to 1%) inside
/// the function's upper and lower bounds (i.e. using the default percentage,
/// the x-values of the intersections between the function and two horizontal
/// lines: one 1% below the function's upper limit, the other 1% above its lower
/// limit).
///
/// In addition to specifying the x-values of these intersections and optionally
/// modifying the percent by which these intersections are inset from the upper
/// and lower bounds of the curve, an `IntuitiveCurve` can also have a
/// customized range. This is achieved by supplying any unique pair of
/// "y-handles", defined by `IntuitiveCurve`'s `YHandle` enum. Each y-handle
/// specifies a conceptual vertical customization point for the curve, as if
/// attaching a draggable handle to the curve at the place indicated by the enum
/// case, as well as an associated value for that handle, as if specifying
/// where, vertically, that handle is dragged. A unique pair of y-handles is
/// both necessary and sufficient to specify the range of the curve, which is
/// why y-handles can only be specified as a tuple of two handles. Passing the
/// same handle for both members of the tuple will cause an exception.
///
/// Once an `IntuitiveCurve` is initialized, its parameters can be accessed but
/// not modified, and function values can be obtained by passing x-inputs into
/// the `apply` closure. (This closure is generated once when it is first
/// accessed and can be saved into a variable, further transformed, and used as
/// needed once it is generatated.)
///
/// **Examples:**
///
///	Create a curve which equals 0.01 at x = 0 and 0.99 at x = 100, with default
/// limits of exactly 0 and 1:
///
///		let curve1 = IntuitiveCurve(from: 0, to: 100)
///
///	Create a curve which equals 0 at x = 0 and 1 at x = 100, with limits
/// slightly below 0 and above 1:
///
///		let curve2 = IntuitiveCurve(from: 0, to: 100,
///			yHandles: (.BottomIntercept(0), .TopIntercept(1)))
///
/// Create a curve which equals 0.1 at x = 0 and 0.9 at x = 100, with default
/// limits of exactly 0 and 1:
///
///		let curve3 = IntuitiveCurve(from: 0, to: 100, insetByPercent: 0.1)
///
/// Create a curve which equals very slightly above 0 at x = 5 and exactly 4 at
/// x = 10 at with a left limit of exactly 0 and a right limit very slightly
/// above 4:
///
///		let curve4 - IntuitiveCurve(from: 5, to: 10,
///			yHandles: (.LeftLimit(0), .TopIntercept(4)), insetByPercent: 0.002)
///
/// - note: To create a decreasing curve, specify a `from` value greater than
///		the `to` value.
///
struct IntuitiveCurve {
	
	/// The different "handles" that can be controlled vertically in an
	/// `IntuitiveCurve`. Cases are listed in decreasing order of where they
	/// would be located vertically on an untransformed `IntuitiveCurve`.
	enum YHandle: Equatable {
		/// The limit of the right asymptote (as x → ∞)
		case RightLimit(Double)
		/// The y value of the intersection between the curve and a horizontal
		/// line located `percentInset` percent in (down if increasing, up if
		/// decreasing) from the right limit.
		case RightIntercept(Double)
		/// The y value of the intersection between the curve and a horizontal
		/// line located `percentInset` percent in (up if increasing, down if
		/// decreasing) from the left limit.
		case LeftIntercept(Double)
		/// The limit of the left asymptote (as x → -∞)
		case LeftLimit(Double)
	}
	
	let rightLimit: Double
	let rightIntersection: (x: Double, y: Double)
	let leftIntersection: (x: Double, y: Double)
	let leftLimit: Double
	
	let percentInset: Double
	
	// The base function used to make the curve. Might want to allow base
	// functions other than tanh to be specified in future.
	let baseFunction: Double -> Double = tanh
	let inverseBaseFunction: Double -> Double = atanh
	
	lazy var apply: Double -> Double = {
		let leftLimitAsPercentageOfRightLimit = self.leftLimit / self.rightLimit
		let a = (1 - leftLimitAsPercentageOfRightLimit) / 2
		let d = 1 - a
		let xDistanceFromStartToEnd = self.rightIntersection.x - self.leftIntersection.x
		let endXUnscaledValue = self.inverseBaseFunction((1 / a) * (self.rightIntersection.y / self.rightLimit - d))
		let startXUnscaledValue = self.inverseBaseFunction((1 / a) * (self.leftIntersection.y / self.rightLimit - d))
		let differenceBetweenUnscaledXValues = endXUnscaledValue - startXUnscaledValue
		let b = differenceBetweenUnscaledXValues / xDistanceFromStartToEnd
		let endXUnshiftedValue = (1 / b) * endXUnscaledValue
		let startXUnshiftedValue = (1 / b) * startXUnscaledValue
		let differenceBetweenXValues = endXUnshiftedValue - startXUnshiftedValue
		let h = differenceBetweenXValues / 2 + self.leftIntersection.x
		let function = transform(self.baseFunction, a: a, b: b, h: h, d: d)
		let scaledFunction = transform(function, a: self.rightLimit)
		return scaledFunction
	}()
	
	init(from: Double, to: Double, withYHandles yHandles: (YHandle, YHandle) = (.LeftLimit(0), .RightLimit(1)), insetByPercent percentInset: Double = 0.01) {
		
		let (handle1, handle2) = yHandles
		guard handle1 != handle2 else { fatalError("The same case cannot be used for both y-handles of an IntuitiveCurve") }
		
		self.percentInset = percentInset
		
		var leftLimit: Double?, leftIntercept: Double?, rightIntercept: Double?, rightLimit: Double?
		
		switch handle1 {
		case .RightLimit(let a): rightLimit = a
		case .RightIntercept(let a): rightIntercept = a
		case .LeftIntercept(let a): leftIntercept = a
		case .LeftLimit(let a): leftLimit = a
		}
		
		switch handle2 {
		case .RightLimit(let a): rightLimit = a
		case .RightIntercept(let a): rightIntercept = a
		case .LeftIntercept(let a): leftIntercept = a
		case .LeftLimit(let a): leftLimit = a
		}
		
		switch (leftLimit, leftIntercept, rightIntercept, rightLimit) {
		case (let leftLimit?, _, _, let rightLimit?):
			leftIntercept = numberScaledByPercentage(percentInset, from: leftLimit, to: rightLimit)
			rightIntercept = numberScaledByPercentage(1 - percentInset, from: leftLimit, to: rightLimit)
		case (let leftLimit?, _, let rightIntercept?, _):
			rightLimit = numberScaledByPercentage(1 / (1 - percentInset), from: leftLimit, to: rightIntercept)
			leftIntercept = numberScaledByPercentage(percentInset, from: leftLimit, to: rightLimit!)
		case (let leftLimit?, let leftIntercept?, _, _):
			rightLimit = numberScaledByPercentage(1 / percentInset, from: leftLimit, to: leftIntercept)
			rightIntercept = numberScaledByPercentage(1 - percentInset, from: leftLimit, to: rightLimit!)
		case (_, let leftIntercept?, _, let rightLimit?):
			leftLimit = numberScaledByPercentage(1 / (1 - percentInset), from: rightLimit, to: leftIntercept)
			rightIntercept = numberScaledByPercentage(1 - percentInset, from: leftLimit!, to: rightLimit)
		case (_, let leftIntercept?, let rightIntercept?, _):
			rightLimit = numberScaledByPercentage((1 - percentInset) / (1 - 2 * percentInset), from: leftIntercept, to: rightIntercept)
			leftLimit = numberScaledByPercentage(1 / (1 - percentInset), from: rightLimit!, to: leftIntercept)
		case (_, _, let rightIntercept?, let rightLimit?):
			leftLimit = numberScaledByPercentage(1 / percentInset, from: rightLimit, to: rightIntercept)
			leftIntercept = numberScaledByPercentage(percentInset, from: leftLimit!, to: rightLimit)
		default: break
		}
		
		self.rightLimit = rightLimit!
		self.rightIntersection = (x: to, y: rightIntercept!)
		self.leftIntersection = (x: from, y: leftIntercept!)
		self.leftLimit = leftLimit!
		
	}
	
}

/// Two YHandles are considered equal iff their cases match (i.e. regardless of
/// their associated values).
func ==(lhs: IntuitiveCurve.YHandle, rhs: IntuitiveCurve.YHandle) -> Bool {
	switch (lhs, rhs) {
	case (.RightLimit, .RightLimit): return true
	case (.RightIntercept, .RightIntercept): return true
	case (.LeftIntercept, .LeftIntercept): return true
	case (.LeftLimit, .LeftLimit): return true
	default: return false
	}
}
