/**
based from jquery's csvExport.
*/

(function($) {
jQuery.fn.table2CSV = function(options) {
    var options = jQuery.extend({
        separator: ';',
        header: [],
        popup: false, // popup, value
		dataRowSelector:'tbody tr:visible',
		headerRowSelector:'thead tr:first-child() th',
		appendHeader:null,
		appendBody:null,
		excludeSelector:'.noCsv'
    },options);

    var csvData = [];
    var headerArr = [];
    var $table = $(this);
	var regexp1 = new RegExp(/"/g);
	var regexp2 = new RegExp(/\s+/g);
//	var regexp2 = new RegExp(/\<[^\<]+\>/g);		

	
    //header
    var numCols = options.header.length;
    var tmpRow = []; // construct header avalible array

    if (numCols > 0) {
        for (var i = 0; i < numCols; i++) {
            tmpRow.push( formatData(options.header[i]));
        }
    } else {
        $table.find(options.headerRowSelector).each(function() {
            if ($(this).css('display') != 'none') tmpRow[tmpRow.length] = formatData($(this).text());
        });
    }
//	if (appendHeader !== null){
//		appendHeader(tmpRow);
//	}
	

    row2CSV(tmpRow);

    // actual data
    $table.find(options.dataRowSelector).each(function(index) {
        var tmpRow = [];
        $(this).children('td').each(function() {
			var $cell =  $(this);
			var tmp;
			if ($cell.css('display') != 'none'){
				if ( $cell.children().length > 1 ){
					tmp = $cell.clone(false);
					tmp.find(options.excludeSelector).remove();
					tmpRow[tmpRow.length] = formatData(tmp.text());
				}
				else{
					tmpRow[tmpRow.length] = formatData($cell.text());
				}
			}
        });
//		if (appendBody!==null){
//			appendBody( tmpRow, $(this),index);
//		}
        row2CSV(tmpRow);
    });
	
	
    if (options.popup ) {
        var mydata = csvData.join('\n');
        return popup(mydata);
    } else {
        var mydata = csvData.join('\n');
        return mydata;
    }

    function row2CSV(tmpRow) {
        var tmp = tmpRow.join('') // to remove any blank rows
        // alert(tmp);
        if (tmpRow.length > 0 && tmp != '') {
            var mystr = tmpRow.join(options.separator);
            csvData[csvData.length] = mystr;
        }
    }
    function formatData(input) {
        // replace " with â€œ
        var output = $.trim(input.replace(regexp1, '""').replace(regexp2,' '));
        //HTML
        if (output == "") return '';
        return '"' + output + '"';
    }
    function popup(data) {
        var generator = window.open('', 'csv', 'height="400",width="600"');
        generator.document.write('<html><head><title>CSV</title>');
        generator.document.write('</head><body >');
        generator.document.write('<textArea cols=70 rows=15 wrap="off" >');
        generator.document.write(data);
        generator.document.write('</textArea>');
        generator.document.write('</body></html>');
        generator.document.close();
        return true;
    }
}

})(jQuery);