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
