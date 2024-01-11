/**
 *  updated: jerikojerk, 
 * 
 * THIS WAS GREAT FEATURE. but i don't know how it worked anymore :D 
 * it was my begin at javascript 
 * 
 *  jQuery ColumnFilter Plugin
 *  @requires jQuery v1.9
 *  http://hernan.amiune.com/labs
 *
 *  Copyright (c)  Hernan Amiune (hernan.amiune.com)
 *  Licensed under MIT license:
 *  http://www.opensource.org/licenses/mit-license.php
 * 
 *  Version: 3.c
 */

(function ($) {
$.fn.columnFilter=function (givenOptions) {

	// handlers definitions bellow-----------------------------------------
	var refreshHandler=function ($table ){
		if (waitId!==null ){
			window.clearTimeout(waitId);
			waitId=null;
		}
		waitId=window.setTimeout(function (){refresh($table);waitId=null;},options.wait);
	}

	var selectItemHandler=function($item,event){
		var cnt;
		if(event.ctrlKey){
			$item.siblings().removeClass(options.selectedFilter);
		}
		if ($item.hasClass(options.selectedFilter)){
			$item.removeClass(options.selectedFilter);
			cnt =0;
		}
		else {
			$item.addClass(options.selectedFilter);
			cnt=1;
		}
		cnt=cnt+$item.siblings('.'+options.selectedFilter).length;
		var $container=$item.parents('.'+options.selectContainer)
		var $btn=$container.siblings('button') ;
		if (cnt>0){
			if($container.find('li:first-child').hasClass(options.selectedFilter)){
				$btn.text((cnt-1)+options.buttonText3);
			}
			else {
				$btn.text(cnt+options.buttonText2);
			}
		}
		else {
			$btn.text(options.buttonText1);
		}
	}

		
	var selectInnerFilterHandler=function( $list, $this ){
		var tmp=$this.val();
		var $all=$list.find('li');
		if (tmp==""){
			$all.show();
		}
		else if (tmp=== "?") {
			$all.hide().filter('li:first-child,li.'+options.selectedFilter).show();
		}
		else {
			var regex=protectRegExp(tmp);
			$all.hide().filter(function(index){return(index==0||regex.test($(this).text()))}).show();
		}
	}
	
	var selectInnerFilterBinder=function($list){
		$list.find('input.'+options.filterSelectInner).keyup(function(){
			selectInnerFilterHandler( $list, $(this));
		});
	}
		
	var filterButtonClickHandler=function ($this,$table){
		var test=$this.siblings('.'+options.selectContainer);
		if (test.length){
			test.toggle();
		}
		else{
			var $td=$this.parent();
			var colindex=$td.parent().children().index($td);
			var $tmp=buildList($table, colindex, options.importFilters); // not so smart... 
			appendList($td,$tmp,$this);
			selectInnerFilterBinder($tmp);
			// avoid un-necessary clicks
			$this.hover(function(){
				if ($tmp.find('.'+options.selectedFilter).length){
					$tmp.show();
				}
			},function(){});
		}
	}
		
	// function definitions bellow
	var sortNumber=function(a,b){
		return a-b;
	}

	var protectRegExp=function(content){
		return new RegExp(content.replace('\\', '\\\\').replace('.','\\.').replace('(','\\(').replace(')','\\)').replace('{','\\{').replace('}','\\}').replace('[','\\[').replace(']','\\]').replace('*','.*').replace('+','\\+'),"mi");
	}
		
	var protectOperator=function(content){
		return content.replace( reg_filterMatcher,"");
	}

	var buildFilterHearders=function($table){
		$table.find(options.headers+'.'+options.filterRow).remove();
		$(options.clearFilters).bind(options.eventClearFilter,function(){clearFilters($table);})
		$table.bind('update.columnFilter',function(){updater($table );});
		var row='<tr class="'+options.filterRow+'">';
		
		//var $headersRow=$table.find( 'thead tr:first-child th');
		$table.find(options.headers).each(function(index){
			var $this=$(this);
			if ($this.hasClass(options.filterNone)){
				row+='<td class="'+options.filterNone+'"></td>';
			}
			else {
				row+=buildFilterHeardersGenerateHtml($this,options.importFilters[index],index);
			}
		});
		$table.find('thead').append(row+'</tr>');
		
		$table.find(options.findInput).click( function (){
			refreshHandler($table);
		}).keyup(function (){
			refreshHandler($table);			
		});
		
		$table.find(options.findButton).click(function(){
			filterButtonClickHandler($(this),$table);
		});
		if (options.importFilters.length>0){
			applyFilters($table,options.importFilters);
		}
	}
		
	var buildFilterHeardersGenerateHtml= function($this,filter,index){
		var tmp,html,buff,content;
		content=$this.text();
		buff=options.forceNoSortingRegex.test( content )?(' '+options.sortType+' '): '';
		
		if (filter){ // can either be undef or null.
			//$headersRow.eq( index ).addClass( options.filterInUse );
			// tune this.
			//placeholder code.
			if ($this.hasClass(options.filterInput)||options.forceInputRegex.test(content)){
				tmp=filter.pattern;
				html='<td class="'+options.filterInput+buff+'"><input type="text" value="'+(tmp?encodeURI(tmp):'')+'" title="simplied regex syntax (by default, ~, !~)  or exact match (=, !=, &gt;, &lt;)"></td>';
			}
			else {
				tmp=filter.list.length;
				if (tmp>0){
					if (filter.positive){
						html='<td class="'+options.filterSelect+buff+'"><button>'+tmp+' '+options.buttonText2+'</button></td>';
					}
					else {
						html='<td class="'+options.filterSelect+buff+'"><button>'+tmp+' '+options.buttonText3+'</button></td>';
					}
				}
				else {
					html='<td class="'+options.filterSelect+buff+'"><button>'+options.buttonText1+'</button></td>';
				}
			}
		}
		else {
			if ($this.hasClass(options.filterInput)||options.forceInputRegex.test(content)){
					html='<td class="'+options.filterInput+buff+'"><input type="text" value="" title="simplied regex syntax (by default, ~, !~)  or exact match (=, !=, &gt;, &lt;)"></td>';
			}
			else {
				html='<td class="'+options.filterSelect+buff+'"><button>'+options.buttonText1+'</button></td>';
			}
		}
		return html;
	}

	var buildList=function($table,colindex,importFilters){
		var filters;
		//var naturalSort=$this.hasClass(options.css.naturalSort);
		var i=0;
		var $list=$('<ul></ul>');

		if ( !importFilters[colindex] ){
			filters={positive:true,list:[],simple:true};
		}
		else{
			filters=importFilters[colindex];
		}
			
		//create a list of items to list in.
		var dictionary=[];
		var tmp;
		$table.find(options.dataRow+' td').filter(':nth-child('+(colindex+1)+')').each(function (){
			tmp=$.trim($(this).text());
			if (dictionary[tmp]){
				dictionary[tmp]++
			}
			else{
				dictionary[tmp]=1;
			}
		});
		var colkeys=[];
		var dontSort=true;
		for (i in dictionary) {
			dontSort=dontSort && reg_float.test(i);
			colkeys.push(i);
		}
		if (dontSort){
			colkeys.sort(sortNumber);
		}else {
			colkeys.sort();
		}
		//add the all row feature...
		buildListItem($list,options.AllRecordsText,filters.positive===false,null);
			
		//build the others options. if there is no filter to restaure it's quite easy 				
		// we have a filter to restaure.
		for (i=0;i<colkeys.length;i++) {
			// can we find the filter in the list ?
			if(colkeys[i]==="indexOf")continue; //weird stuff happens in ie and chrome, firefox is awesome
			var fi;
			var test=false;
			for (fi=0;fi<filters.list.length;fi++){
				if (filters.list[fi]===colkeys[i]){
					test=true;
					break;
				}
			}
			buildListItem( $list, colkeys[i], test, dictionary[colkeys[i]] );
		} // looping on colkeys
						
		//bind change function to each list filter
		$list.find('li').click( function (event){
			selectItemHandler($(this),event);
			refreshHandler( $table );
		});
			
		var tmp=$('<div class="'+options.selectContainer+'" ></div>');
		buildListInnerFilter(tmp);
		tmp.append($list);			
		return tmp;
	}
		
	var buildListItem=function( $list, itemValue, selected, count ){
		var tmp,title;
		title=count!==null?' title="'+count+' row(s)" ':'';
			
		if (selected){
			tmp='<li '+title+'class="'+options.selectedFilter+'"></li>';
		}
		else{
			tmp='<li '+title+'></li>';
		}
		$list.append( $(tmp).text(itemValue) );
	}
		
	var buildListInnerFilter=function($tmp){
		$tmp.append( '<p title="use input to filter below choices, write ? to see selected, simplied regex syntax" ><input class="'+options.filterSelectInner+'" type="text" value="" placeholder="box search"/></p>' );
	}
		
		
	var appendList=function($parent,$child,$refposition){
		$parent.append( $child );
		var position=$refposition.position();
		$parent.position({left:position.left,top:position.botton+2});
	}
		
	var refresh=function($table){
		var tmp=readFilters($table);
		applyFilters( $table, tmp );
	}
	
	var readFilters=function($table){
		//create an array of the filters selected values
		var activeFilters=[];
		//remove activeFilters on headers..
		$table.find(options.findSelectFilter).each(function(index2){
			var tmp;
			var $this=$(this); // li.selectedFilter
			var content=$this.text();
			var $parent=$this.parents('td'); // the open cell.
			//todo verify with index2 vs index
			var index=$parent.parent('tr').children().index($parent);			
			if (!activeFilters[index]){
				tmp={positive:true,list:[],simple:true};
				activeFilters[index]=tmp;
			}
			tmp=activeFilters[index];
			if (content != options.AllRecordsText){
				tmp.list.push(content);
			}
			else {
				tmp.positive=false;
			}
			activeFilters[index]=tmp;
			});
			
			
		$table.find(options.findInput).each(function () {
			var $this=$(this);
			var content=$.trim( $this.val());
			if ( content.length>0  ){
				var $parent=$this.parents('td');
				var index=$parent.parents('tr').children().index($parent);
				var op=content.match(reg_filterMatcher);
				var x;
				var positive=true;
				var floatval;
				if (op!==null){
					op=op[1];
					if ((op == "<"||op == ">")||(op=="=")){
						x=true;
					}
					else if (op=="!="){
						x=true;positive=false;op="=";
					}
					else if (op=="!~"){
						x=false;positive=false;op="~";
					}
					else /* op == "~"*/ {
						op="~";x=false;
					}
					content=protectOperator(content);
				}
				else{
					x=false;op="~";
				}
				var convert=x&&reg_float.test(content);
				var tmp={positive:positive,list:[],simple:false,pattern:(x?content:protectRegExp(content)),operator:op,convert:convert};
				activeFilters[index]=tmp;
			}
		});
		return activeFilters;
	}
		
		var applyFilters=function($table,activeFilters){
			var displayed=0;
			var hidden=0;
			var len=activeFilters.length;
			var i,test;
			//in refresh... show or hide.			
			$table.find(' .'+options.filterInUse ).removeClass(options.filterInUse);
			var $headers=$table.find(options.headers);
			var $footers=$table.find(options.footers);
			test=false;
			for (i=0;i<len;i++){
				if ( activeFilters[i] ){
					$headers.eq(i).addClass(options.filterInUse);
					$footers.eq(i).addClass(options.filterInUse);
					test=true;
				}
			}//for
			delete $headers;
			delete $footers;
			
			if (test) {
				$(options.clearFilters).removeAttr("disabled")
			}
			else{
				$(options.clearFilters).attr("disabled", "disabled");
			}
			
			$table.find(options.dataRow).each(function () {
				var rowok=true;
				var $row=$(this);
				var i, j, n;
				var content,copy;
				var childs=$row.children('td');
				var tmp,cellok,len2,ref,convert;
				for (i=0;i<len;i++) {
					if (activeFilters[i]){
						n= childs.eq(i);
						content=$.trim(n.text()); //filter(':not('+options.ignoreSelector+')')
						tmp=activeFilters[i];						
						cellok=!tmp.positive;
						if (tmp.simple){
							len2=tmp.list.length;
							for (j=0; j<len2;j++){
								if (tmp.list[j]==content){cellok=tmp.positive;break;}
							}
						}
						else { // tmp.simple -> vial la regex
							if (tmp.convert){
								if (!tmp.converted){tmp.converted=parseFloat(tmp.pattern)}
								if (reg_float.test(content)){content=parseFloat(content);ref=tmp.converted;}
								else{ref=tmp.pattern;}
							}
							else {
								ref= tmp.pattern
							}
							
							if (tmp.operator==="="){
								if (content==ref){cellok=tmp.positive;}
							}
							else if (tmp.operator===">"){
								if ( content > ref ){cellok=true;}
							}
							else if (tmp.operator==="<"){
								if (content<ref){cellok=true;}
							}
							else {
								if (tmp.pattern.test(content)){cellok=tmp.positive;}
							}
						}
						rowok=rowok && cellok;
					}	
					if (rowok==false){break;}
				}
				if (rowok === true){
					$row.show();displayed++;
				}
				else {
					$row.hide();hidden++;
				}
			});//hide row.
			
			$(options.countDisplay).text(displayed);
			options.exportFilters($table,activeFilters);

		}

		// quickly remove filters.
		var clearFilters=function ($table){
			$table.find( '.'+options.filterInUse ).removeClass(options.filterInUse);
			$table.find(options.findSelectFilter ).removeClass(options.selectedFilter);
			$table.find(options.findInput).val('');
			var tmp=$table.find(options.dataRow);
			tmp.show();
			$(options.countDisplay).text(tmp.length);
			$(options.clearFilters).attr("disabled", "disabled");
		}

		var updater=function ($table){
			var activeFilters=readFilters($table);
			$table.find(options.findSelectContainer).each(function(){
				var $this=$(this);
				var visible=$this.css('display');
				var $button=$this.siblings('button');
				var $td=$this.parent();
				var colindex=$td.parent().children().index($td);
				$this.remove();
				var $tmp=buildList($table,colindex,activeFilters);
				appendList($td,$tmp,$button);
				selectInnerFilterBinder($tmp);
				$tmp.css('display',visible);
			});
			applyFilters($table,activeFilters);
		}		
		
		var exportHandler=function($table,activeFilters){
			//alert( "please overload this function");
		}
		
		var returnClosure=function($table){
			if (options.action==options.action_export){
				var data=[];
				$table.each(function (index){
					data[index]=readFilters($(this));
				});
				return data;
			}
			else {// ( options.action == options.action_build ){
				$table.each(function(){
					var $this=$(this);
					buildFilterHearders( $this );
				});
			}
		}


		
//---------------------------------------------------------------
// now we can go with datas.
		var waitId=null;
		var defaults ={
			action_build:"build",
			action_export:"export",
			filterSelect:'filterSelect',
			filterNone: 'filterNone',
			filterInput:'filterWrite',
			filterSelectInner:'innerFilter',
			filterRow: 'filterRow', 	// all rows containing filter in my table
			sortType: 'naturalSort',	// working ? implemented ?
			forceInputRegex :/.*ID/,	// if match, td container will have  filterInput class
			forceNoSortingRegex: /#/, // if match, add .sortType to the td container
			buttonText1: 'Filter...',
			buttonText2: ' selected',
			buttonText3: ' excluded',
			selectContainer: 'filterContainer',
			AllRecordsText:"All (but...)",
			AllRecordsClass:"filterAll",
			exportFilters: exportHandler,
			countDisplay:'#rowFilteredCount',
			clearFilters:'#clearFilters',
			selectedFilter: 'selectedFilter',
			filterInUse: 'activeFilter',
			headers: 'thead th', 	//search for hearder
			footers:'tfoot th',		//search for for footer
			dataRow:'tbody tr',		//search for data here
			eventClearFilter:'click',	//?
			action:'build',			// ?
			importFilters:[],		// filter to restore 
			wait:800,				// wait before refilter
			contentIgnore:'.noCsv' 	//ignore this, not implemented.
			};
		var reg_float=/^(\-|\+)?([0-9]+(\.[0-9]+)?)$/;
		var reg_filterMatcher=/^([=><!~]+)\s*/;
		var reg_integer=/^(\-|\+)?\d+$/
        var options=$.extend(defaults, givenOptions);
		options.findInput='thead .'+options.filterRow+' td.'+options.filterInput+' input';
		options.findButton='thead .'+options.filterRow+' button';
		options.findSelectFilter='thead .'+options.filterRow+' .'+options.selectedFilter;
		options.findSelectContainer='thead .'+options.filterRow+' .'+options.selectContainer;
		return returnClosure($(this));
	}
	
	
	$.fn.columnfilter=$.fn.columnFilter;
})(jQuery);

