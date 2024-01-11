/*! ISO-8601 date parser
 * This parser will work with dates in ISO8601 format
 * 2013-02-18T18:18:44+00:00
 * Written by Sean Ellingham :https://github.com/seanellingham
 * See https://github.com/Mottie/tablesorter/issues/247
 */
/*global jQuery: false */
;(function($){
"use strict";

	var isoPEPdate = /^([0-9]{4})-([0-9]{2})-([0-9]{2})\s+([0-9]{2}):([0-9]{2})(?:([0-9]{2}))?/;
	$.tablesorter.addParser({
		id : 'isoPEPdate',
		is : function(s) {

			return s.match(isoPEPdate);
		},
		format : function(s) {
			//alert(s);
			var result = s.match(isoPEPdate);
			if (result) {
				var date = new Date(result[1], 0, 1);
				date.setMonth(result[2] - 1);
				date.setDate(result[3]);
				date.setHours(result[4]);
				date.setMinutes(result[5]);
				if (result[6]){ date.setSeconds(result[6]); }
				return date;
			}
			return s;
		},
		type : 'numeric'
	});

})(jQuery);
