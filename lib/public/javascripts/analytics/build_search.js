$(function(){

	var $table = $('table.build_chart_analytics');

	$table.find('a.build_chart_analytics_vs:first').click(function(){
		var f = $table.find('tr:first').clone();
		var l = $table.find('tr:last').detach();

		var image = f.find('img');
		image.attr('src', '/admin_data/public/images/no.png');

		f.find('a').removeClass('build_chart_analytics_vs').addClass('del');

		$table.append(f).append(l);

		return false;
	});

});

$('table.build_chart_analytics a.del').live('click', function(e){

	$(e.target).closest('tr').remove();

}); 
