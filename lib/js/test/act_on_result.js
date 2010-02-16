module('act_on_result', {
	teardown: function() {
		$('#advance_search_delete_all').remove();
		$('#advance_search_destroy_all').remove();
		$('#results').remove();
		$('#advance_search_form').remove();
	},
	setup: function() {
		$(document.body).append($('<a />', {
			href: '#',
			id: 'advance_search_delete_all'
		}));
		$(document.body).append($('<a />', {
			href: '#',
			id: 'advance_search_destroy_all'
		}));
		$(document.body).append($('<div />', {
			id: 'results'
		}));
		$(document.body).append($('<div />', {
			id: 'advance_search_form'
		}));
	}
});

test('invoking success callback', function() {
	expect(1);
	AdminData.actOnResult.successCallback({
		success: 'hello world'
	});
	equals('hello world', $('#results').text(), '#results should have text hello world');
});

test('live clicking #advance_search_delete_all with cancel action', function() {
	expect(0);
	jack(function() {
		jack.expect('AdminData.jsUtil.confirm').exactly('1 time').mock(function() {
			return false;
		});
		jack.expect('AdminData.actOnResult').exactly('0 time');
		$('#advance_search_delete_all').trigger('click');
	});
});

test('live clicking #advance_search_delete_all', function() {
	expect(0);
	jack(function() {
		jack.expect('AdminData.jsUtil.confirm').exactly('1 time').mock(function() {
			return true;
		});
		jack.expect('AdminData.actOnResult').exactly('1 time').mock(function() {
			return {};
		});
		$('#advance_search_delete_all').trigger('click');
	});
});

test('live clicking #advance_search_destroy_all with cancel action', function() {
	expect(0);
	jack(function() {
		jack.expect('AdminData.jsUtil.confirm').exactly('1 time').mock(function() {
			return false;
		});
		jack.expect('AdminData.actOnResult').exactly('0 time');
		$('#advance_search_destroy_all').trigger('click');
	});
});

test('live clicking #advance_search_destroy_all', function() {
	expect(0);
	jack(function() {
		jack.expect('AdminData.jsUtil.confirm').exactly('1 time').mock(function() {
			return true;
		});
		jack.expect('AdminData.actOnResult').exactly('1 time').mock(function() {
			return {};
		});
		$('#advance_search_destroy_all').trigger('click');
	});
});

test('actOnResultAJAX', function() {
	expect(0);
	$('#advance_search_form').data('admin_data_form_array', [{
		name: 'foo',
		value: 'i_am_foo'
	}]);
	jack(function() {
		jack.expect('$.ajax').exactly('1 time').mock(function() {
			return {};
		});
		//TODO test for arguments
		AdminData.actOnResult('delete');
	});
});

