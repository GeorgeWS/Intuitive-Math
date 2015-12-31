//
//  Created by George Woodliff-Stanley on 12/31/15.
//  Copyright (c) 2015 George Woodliff-Stanley.
//

/// Create a random number generator whose outputs are within a given range.
func random(var from from: CGFloat, var to: CGFloat) -> Void -> CGFloat {
	if to < from { swap(&to, &from) }
	return { _ in
		(((CGFloat(arc4random())
			% (CGFloat(UInt32.max) + 1))
			/ CGFloat(UInt32.max))
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
