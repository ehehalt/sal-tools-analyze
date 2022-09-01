#!/opt/local/bin/ruby
# coding: utf-8

require 'minitest/autorun'
require_relative '../lib/sal/errorlog'

class TestErrorLog < MiniTest::Test

  def setup
    @err_file_42 = "data/test.42.err"
  end

  def test_errorlog_42
    log = Sal::ErrorLog.new @err_file_42

    assert_equal(2, log.errors.count)

    error1 = log.errors[0]

    assert_equal("Set hWndDateTimeF = SalCreateWindowEx( frmDF_DateTime, hParent, nLeft, nTop, nW, nH, CREATE_AsChild, hWndItem,nColor)", error1.code)
    assert_equal(49, error1.position)
    assert_equal("Symbol is undefined or unable to be referenced from current location: frmDF_DateTime", error1.message)

    error2 = log.errors[1]

    assert_equal("Call GalExcelExportDialog( hWndForm, strText, 0, sUserINIFileName, sGHSini_FileName, sGhsMSGFileName, sGhsMSG_Hint_FileName, strText )", error2.code)
    assert_equal(20, error2.position)
    assert_equal("Undefined function: GalExcelExportDialog", error2.message)

    nfr_count = log.nfr_count

    assert_equal(12, nfr_count)
  end

end

MiniTest.autorun