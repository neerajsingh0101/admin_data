$(function(){

	var $table = $('table.build_chart_analytics');

	$table.find('a.build_chart_analytics_vs:first').click(function(){
		var f = $table.find('tr:first').clone(),
			l = $table.find('tr:last').detach(),
			image = f.find('img'),
			randomNumber = AdminData.jsUtil.randomNumber();

		image.attr('src', '/admin_data/public/images/no.png');

		f.find('a').removeClass('build_chart_analytics_vs').addClass('del');

		f.find('td.col1 select').attr('name', 'search[row_'+randomNumber+']klass');
		f.find('td.col2 select').attr('name', 'search[row_'+randomNumber+']with_type');
		f.find('td.col3 select').attr('name', 'search[row_'+randomNumber+']relationship');

		$table.append(f).append(l);

		return false;
	});

});

$('table.build_chart_analytics a.del').live('click', function(e){

	$(e.target).closest('tr').remove();

}); 
