module('advance_search');

test("buildCol1", function() {
  expect(3);

  var $tr = AdminData.advanceSearch.buildCol1();
  ok( $.isjQuery($tr), "buildCol1 should return an instance of jQuery");


  var className = $tr.find('select').attr('className');
  equals('col1', className, 'buildCol1 should have select with class col1');

  var countOfOptions = $tr.find('select option').length;
  equals(12, countOfOptions, 'buildCol1 should have select with 12 options');

});

test("buildCol2", function() {
  expect(3);

  var $tr = AdminData.advanceSearch.buildCol2();
  ok( $.isjQuery($tr), "buildCol2 should return an instance of jQuery");


  ok($tr.find('select').hasClass('col2'), 'buildCol2 should have class col2');
  ok($tr.find('select').hasClass('disabled'), 'buildCol2 should have class disabled');

});
