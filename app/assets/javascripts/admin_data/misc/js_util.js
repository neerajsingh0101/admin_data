var AdminData = AdminData || {};

/**
 * A general Utility
 * @namespace AdminData
 * @class jsUtil
 */
AdminData.jsUtil = {

  // TODO since advance search was not working with util confirm , window.confirm is used directly
  // fix it later
	confirm: function(arg) {
		window.confirm(arg);
	},

	buildOptionsFromArray: function(array, element) {
		element.append($('<option />'));
		for (i in array) {
			$('<option />').text(array[i][0]).attr('value', array[i][1]).appendTo(element);
		}
		element.attr('disabled', false);
	},

	colorizeRows: function() {
		$('.colorize tr:odd').addClass('odd');
		$('.colorize tr:even').addClass('even');
	},

  /**
   * Returns the input date in string format.
   *
   * @param {date} input date 
   * @return {string} The string value of input date
   */
	dateToString: function(date) {
		var month = (date.getMonth() + 1).toString();
		var day = date.getDate().toString();
		//days between 1 and 9 should have 0 before them
		if (day.length == 1) day = '0' + day;
		var months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
		return day + "-" + months[month - 1] + "-" + date.getFullYear();
	},

  /**
   * Generate a random number between 1 and 10000000
   *
   * @return {Integer} a random Integer
   *
   */
	randomNumber: function() {
		var maxVal = 100000000,
		minVal = 1;
		var randVal = minVal + (Math.random() * (maxVal - minVal));
		return Math.round(randVal);
	}

};

