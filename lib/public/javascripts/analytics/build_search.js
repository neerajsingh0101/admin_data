$(function(){

	var $table = $('table.build_chart_analytics');

	$table.find('td.operator_value input').attr('disabled', 'disabled');

	$table.find('a.build_chart_analytics_vs:first').click(function(){
		var f = $table.find('tr:first').clone(),
			l = $table.find('tr:last').detach(),
			image = f.find('img'),
			randomNumber = AdminData.jsUtil.randomNumber();

		image.attr('src', '/admin_data/public/images/no.png');

		f.find('a').removeClass('build_chart_analytics_vs').addClass('del');

		f.find('td.main_klass select').attr('name', 'search[row_'+randomNumber+']klass');
		f.find('td.with_type select').attr('name', 'search[row_'+randomNumber+']with_type');
		f.find('td.relationship select').attr('name', 'search[row_'+randomNumber+']relationship');

		$table.append(f).append(l);

		return false;
	});

});

$('table.build_chart_analytics a.del').live('click', function(e){

	$(e.target).closest('tr').remove();

}); 

$('table.build_chart_analytics td.operator select').live('change', function(e){

	var $target = $(e.target),
	    value = $target.closest('select').val(),
	    $input;
	
	if (value.replace(/\s/g) === '') {
		$input = $target.closest('tr').find('td.operator_value input');
        $input.val('');
		$input.attr('disabled', 'disabled');
	} else {
		$target.closest('tr').find('td.operator_value input').removeAttr('disabled');
	}

});
