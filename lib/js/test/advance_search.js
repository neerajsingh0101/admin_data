test("buildCol1", function() {
  var $tr = AdminData.advanceSearch.buildCol1();
  ok( $.isjQuery($tr), "buildCol1 should return an instance of jQuery");


  var className = $tr.find('select').attr('className');
  equals('col1', className, 'buildCol1 should have select with class col1');

});

