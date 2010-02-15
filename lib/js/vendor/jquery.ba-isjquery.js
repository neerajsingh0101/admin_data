/*!
 * jQuery isjQuery - v0.4 - 2/13/2010
 * http://benalman.com/projects/jquery-misc-plugins/
 * 
 * Copyright (c) 2010 "Cowboy" Ben Alman
 * Dual licensed under the MIT and GPL licenses.
 * http://benalman.com/about/license/
 */

// Since every jQuery object has a .jquery property, it's usually safe to test
// the existence of that property. Of course, this only works as long as you
// know that any non-jQuery object you might be testing has no .jquery property.
// So.. what do you do when you need to test an external object whose properties
// you don't know?
// 
// If you currently use instanceof, read this Ajaxian article:
// http://ajaxian.com/archives/working-aroung-the-instanceof-memory-leak

jQuery.isjQuery = function( obj ){
  return obj && obj.hasOwnProperty && obj instanceof jQuery;
};
