module('act_on_result', {
	teardown: function() {
		$('#advance_search_delete_all').remove();
		$('#advance_search_destroy_all').remove();

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

	}
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

