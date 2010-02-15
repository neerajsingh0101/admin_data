module('advance_search');

test("buildCol1", function() {
  expect(3);

  var $td = AdminData.advanceSearch.buildCol1();
  ok( $.isjQuery($td), "buildCol1 should return an instance of jQuery");

  var className = $td.find('select').attr('className');
  equals('col1', className, 'buildCol1 should have select with class col1');

  var countOfOptions = $td.find('select option').length;
  equals(12, countOfOptions, 'buildCol1 should have select with 12 options');
});

test("buildCol2", function() {
  expect(3);

  var $td = AdminData.advanceSearch.buildCol2();
  ok( $.isjQuery($td), "buildCol2 should return an instance of jQuery");

  ok($td.find('select').hasClass('col2'), 'buildCol2 should have class col2');
  ok($td.find('select').hasClass('disabled'), 'buildCol2 should have class disabled');
});

test("buildCol3", function() {
  expect(3);

  var $td = AdminData.advanceSearch.buildCol3();
  ok( $.isjQuery($td), "buildCol3 should return an instance of jQuery");

  ok($td.find('input').hasClass('col3'), 'buildCol3 should have input element with class col3');
  ok($td.find('input').attr('disabled'), 'buildCol3 should have input element with attribute disabled');
});

test("buildCol4", function() {
  expect(3);

  var $td = AdminData.advanceSearch.buildCol4();
  ok( $.isjQuery($td), "buildCol4 should return an instance of jQuery");

  var a = $td.find('a');
  ok(a.hasClass('remove_row'), 'buildCol4 should have anchor element with class remove_row');
  equals('x', a.text(), 'buildCol4 should have anchor element with text x');
});

test("buildRow", function() {
  expect(2);

  var $tr = AdminData.advanceSearch.buildRow();
  ok( $.isjQuery($tr), "buildCol4 should return an instance of jQuery");

  equals(4, $tr.find('td').length, 'buildRow should have 4 td elements');
});



