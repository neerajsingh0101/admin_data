var AdminData = AdminData || {};
AdminData.analytics = AdminData.analytics || {};

$(function(){
  AdminData.analytics.allAssociationInfo = $.parseJSON( $('#all_association_info').html());
});

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

AdminData.analytics.disableOperator = function(e){
	var $target = $(e.target), $select, $input;

	$select = $target.closest('tr').find('td.operator select');
	$select.val('');
	$select.attr('disabled', 'disabled');

	$input = $target.closest('tr').find('td.operator_value input');
	$input.val('');
	$input.attr('disabled', 'disabled');
}

AdminData.analytics.enableOperator = function(e){
	var $target = $(e.target), $select, $input;

	$select = $target.closest('tr').find('td.operator select');
	$select.removeAttr('disabled');

	$input = $target.closest('tr').find('td.operator_value input');
	$input.removeAttr('disabled');
};

$('table.build_chart_analytics td.relationship select').live('change', function(e){

	var $target = $(e.target),
	    value = $target.closest('select').val(),
	    $input,
	    associationType;
	
	if (value.replace(/\s/g) === '') {
		AdminData.analytics.disableOperator(e);
	} else {
		associationType = AdminData.analytics.allAssociationInfo[value];

		if (associationType == 'has_one') {
			AdminData.analytics.disableOperator(e);
		} else {
			AdminData.analytics.enableOperator(e);
		}
	}

});

$('table.build_chart_analytics td.with_type select').live('change', function(e){

	var $target = $(e.target),
	    value = $target.closest('select').val(),
	    $input,
	    associationType;
	
	if (value === 'with') {
		var relationshipVal = $target.closest('tr').find('td.relationship select').val();
		if (relationshipVal.replace(/\s/g) === '') {
			AdminData.analytics.disableOperator(e);
		} else {
			AdminData.analytics.enableOperator(e);
		}
	} else {
		AdminData.analytics.disableOperator(e);
	}

});
