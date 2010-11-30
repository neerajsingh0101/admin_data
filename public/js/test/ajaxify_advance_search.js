module('ajaxify advance search', {
	teardown: function() {
		$('#results').remove();
		$('#advance_search_form').remove();
	},
	setup: function() {
		$(document.body).append($('<div />', {
			id: 'results'
		}));
		$(document.body).append($('<div />', {
			id: 'advance_search_form'
		}));
	}
});

test('successCallback', function() {
	expect(1);
	AdminData.ajaxifyAdvanceSearch.successCallback('hello world');
	equals('hello world', $('#results').text(), '#results should have text hello world');
});

test('beforeSubmitCallback', function() {
	expect(1);
	AdminData.ajaxifyAdvanceSearch.beforeSubmitCallback(['1', '2'], null);

	var $results = $('#results');
	equals('searching...', $('#results').text(), '#results should have text searching');
});

