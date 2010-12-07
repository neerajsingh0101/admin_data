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
		jack.expect('AdminData.jsUtil.confirm').once().mock(function() {
			return false;
		});
		//TODO ensure that the value passed to action is delete
		jack.expect('AdminData.actOnResult.action').exactly('0 time');
		$('#advance_search_delete_all').trigger('click');
	});
});

test('live clicking #advance_search_delete_all', function() {
	expect(0);
	var args;

	jack(function() {
		jack.expect('AdminData.jsUtil.confirm').once().mock(function() {
			return true;
		});
		jack.expect('AdminData.actOnResult.action').once().mock(function(action_type) {
			args = action_type;
			return {};
		});
		$('#advance_search_delete_all').trigger('click');
	});
  equals('delete', args, 'action_type should be delete');

});

test('live clicking #advance_search_destroy_all with cancel action', function() {
	expect(0);
	jack(function() {
		jack.expect('AdminData.jsUtil.confirm').once().mock(function() {
			return false;
		});
		jack.expect('AdminData.actOnResult.action').exactly('0 time');
		$('#advance_search_destroy_all').trigger('click');
	});
});

test('live clicking #advance_search_destroy_all', function() {
	expect(0);
	var args;

	jack(function() {
		jack.expect('AdminData.jsUtil.confirm').once().mock(function() {
			return true;
		});
		jack.expect('AdminData.actOnResult.action').once().mock(function(action_type) {
			args = action_type;
			return {};
		});
		$('#advance_search_destroy_all').trigger('click');
	});
	equals('destroy', args, 'action_type should be destroy');
});

test('actOnResultAJAX', function() {
	expect(5);
	$('#advance_search_form').attr('action', 'http://localhost:3000');
	$('#advance_search_form').data('admin_data_form_array', [{
		name: 'foo',
		value: 'i_am_foo'
	}]);

	var ajaxArgs;

	jack(function() {
		jack.expect('$.ajax').once().mock(function(args) {
			ajaxArgs = args;
		});
		AdminData.actOnResult.action('delete');
	});

	equals('post', ajaxArgs.type, 'ajax arguments should have type as post');
	equals('json', ajaxArgs.dataType, 'ajax arguments should have json as dataType');
	equals('http://localhost:3000', ajaxArgs.url, 'ajax arguments should have valid url');
	var data = ajaxArgs.data;
	ok(data, 'ajax arguments should have value for key data');
	equals('foo=i_am_foo&admin_data_advance_search_action_type=delete', data, 'data should have parameterized value');

});

