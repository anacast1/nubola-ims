require File.dirname(__FILE__) + '/../test_helper'

class HostTest < Test::Unit::TestCase
  fixtures :hosts

  def test_add_host
    xml = <<EOF
<addhost gid="#{Fixtures.identify(:ingent)}" hostname="petitet_per_ingent.oaproject.net">
  <parameters>
    <param name="cpu">100</param>
    <param name="ram">256</param>
    <param name="disk">400</param>
  </parameters>
</addhost>
EOF
    host=hosts(:virtual_petit)
    assert_equal(xml, host.addhost_message)
  end

  def test_modify_host
    xml = <<EOF
<modifyhost gid="#{Fixtures.identify(:ingent)}" hostname="petitet_per_ingent.oaproject.net">
  <parameters>
    <param name="cpu">100</param>
    <param name="ram">256</param>
    <param name="disk">400</param>
  </parameters>
</modifyhost>
EOF
    host=hosts(:virtual_petit)
    assert_equal(xml, host.modifyhost_message)
  end

  def test_delete_host
    xml = "<delhost gid=\"#{Fixtures.identify(:ingent)}\" hostname=\"petitet_per_ingent.oaproject.net\"/>"
    host=hosts(:virtual_petit)
    assert_equal(xml, host.delhost_message)
  end

end
