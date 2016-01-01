//
//  Created by George Woodliff-Stanley on 12/31/15.
//  Copyright (c) 2015 George Woodliff-Stanley.
//

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
	
	/// Specifies the different "handles" that can be controlled vertically in
	/// an `IntuitiveCurve`. Cases are spcefified in decreasing order on an
	/// untransformed `IntuitiveCurve`.
	///
	/// - cases:
	///		- RightLimit: the limit of the right asymptote (as x → ∞)
	///		- TopIntercept: the y value of the intersection between the curve
	///			and a horizontal line located `percentInset` percent down from
	///			the top (right if increasing, left if decreasing) limit.
	///		- BottomIntercept: the y value of the intersection between the curve
	///			and a horizontal line located `percentInset` percent up from the
	///			bottom (left if increasing, right if decreasing) limit.
	///		- LeftLimit: the limit of the left asymptote (as x → -∞)
	enum YHandle: Equatable {
		case RightLimit(Double)
		case TopIntercept(Double)
		case BottomIntercept(Double)
		case LeftLimit(Double)
	}
	
	let rightLimit: Double
	let leftLimit: Double
	let topIntercection: (x: Double, y: Double)
	let bottomIntersection: (x: Double, y: Double)
	let percentInset: Double
	
	// The base function used to make the curve. Might want to allow base
	// functions other than tanh to be specified in future.
	let baseFunction: Double -> Double = tanh
	let inverseBaseFunction: Double -> Double = atanh
	
	lazy var apply: Double -> Double
	
	init(from: Double, to: Double, withYHandles yHandles: (YHandle, YHandle) = (.LeftLimit(0), .RightLimit(1)), insetByPercent percentInset: Double = 0.01)
	
}

/// Two YHandles are considered equal iff their cases match (i.e. regardless of
/// their associated values).
func ==(lhs: IntuitiveCurve.YHandle, rhs: IntuitiveCurve.YHandle) -> Bool {
	switch (lhs, rhs) {
	case (.RightLimit, .RightLimit): return true
	case (.LeftLimit, .LeftLimit): return true
	case (.TopIntercept, .TopIntercept): return true
	case (.BottomIntercept, .BottomIntercept): return true
	default: return false
	}
}
