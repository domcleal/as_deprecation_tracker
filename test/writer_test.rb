# frozen_string_literal: true
require 'test_helper'

class WriterTest < ASDeprecationTracker::TestCase
  def test_add
    writer = new_writer
    writer.add('deprecated call', ['a.rb:23', 'b.rb:42'])
    assert_equal [{ 'message' => 'deprecated call', 'callstack' => 'a.rb:23' }], YAML.load(writer.contents)
  end

  def test_add_strips_surrounding
    writer = new_writer
    writer.add('DEPRECATION WARNING: deprecated call (called from a.rb:23)', ['a.rb:23', 'b.rb:42'])
    assert_equal [{ 'message' => 'deprecated call', 'callstack' => 'a.rb:23' }], YAML.load(writer.contents)
  end

  def test_contents_new_file_is_array
    assert_equal [], YAML.load(new_writer('').contents)
  end

  def test_contents_sorting
    writer = new_writer
    writer.add('deprecated call 1', ['a.rb:42', 'b.rb:42'])
    writer.add('deprecated call 2', ['a.rb:23', 'b.rb:42'])
    writer.add('deprecated call 1', ['a.rb:23', 'b.rb:42'])
    assert_equal [
      { 'message' => 'deprecated call 1', 'callstack' => 'a.rb:23' },
      { 'message' => 'deprecated call 1', 'callstack' => 'a.rb:42' },
      { 'message' => 'deprecated call 2', 'callstack' => 'a.rb:23' }
    ], YAML.load(writer.contents)
  end

  def test_write_file
    writer = new_writer
    writer.expects(:contents).returns('--- []')
    File.expects(:write).with('root/config/as_deprecation_whitelist.yaml', '--- []')
    writer.write_file
  end

  private

  def new_writer(input = '')
    File.expects(:exist?).with('root/config/as_deprecation_whitelist.yaml').returns(true)
    File.expects(:read).with('root/config/as_deprecation_whitelist.yaml').returns(input)
    ASDeprecationTracker::Writer.new('root/config/as_deprecation_whitelist.yaml')
  end
end
