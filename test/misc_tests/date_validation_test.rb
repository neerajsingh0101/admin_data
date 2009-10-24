require 'test/test_helper'

require File.expand_path(File.join(File.dirname(__FILE__), '../../../admin_data/lib/admin_data_date_validation'))

class AdminDataTest < Test::Unit::TestCase

  def test_date_validation

    assert ::AdminDataDateValidation.validate('13-feb-2009')
    assert ::AdminDataDateValidation.validate('13-FEB-2009')
    assert ::AdminDataDateValidation.validate('13-feb -2009')    # extra white space should not hurt

    # only the first three characters of the month should be checked
    assert ::AdminDataDateValidation.validate('13-FEBfoo-2009')

    assert !::AdminDataDateValidation.validate('13-foo-2009')    # month name is wrong
    assert !::AdminDataDateValidation.validate('13 foo 2009')    # there must be two occurences of -
    assert !::AdminDataDateValidation.validate('32-jan-2009')    # day is wrong
    assert !::AdminDataDateValidation.validate('32-jan- -2009')  # there should be only two occurences of -
    assert !::AdminDataDateValidation.validate('32-jan-09')      # year must be greater than 1900
  end

  def test_date_validation_with_operator
    assert ::AdminDataDateValidation.validate_with_operator('> 13-feb-2009')
    assert ::AdminDataDateValidation.validate_with_operator('>= 13-feb-2009')
    assert ::AdminDataDateValidation.validate_with_operator('< 13-feb-2009')
    assert ::AdminDataDateValidation.validate_with_operator('<= 13-feb-2009')

    assert !::AdminDataDateValidation.validate_with_operator('<=13-feb-2009')  # no white space
    assert !::AdminDataDateValidation.validate_with_operator('| 13-feb-2009')   # invalid operator
  end

end
