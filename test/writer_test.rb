# frozen_string_literal: true
require 'test_helper'

class WriterTest < ASDeprecationTracker::TestCase
  def test_add
    writer = new_writer
    writer.add('deprecated call', ['app/models/a.rb:23', 'app/models/b.rb:42'])
    assert_equal [{ 'message' => 'deprecated call', 'callstack' => 'app/models/a.rb:23' }], YAML.safe_load(writer.contents)
  end

  def test_add_strips_surrounding
    writer = new_writer
    writer.add('DEPRECATION WARNING: deprecated call (called from app/models/a.rb:23)', ['app/models/a.rb:23', 'app/models/b.rb:42'])
    assert_equal [{ 'message' => 'deprecated call', 'callstack' => 'app/models/a.rb:23' }], YAML.safe_load(writer.contents)
  end

  def test_add_cleans_callstack
    writer = new_writer
    Gem.expects(:path).returns(['/home/user/.rvm/gems/ruby-2.3.0'])
    writer.add('deprecated call', ['/home/user/.rvm/gems/ruby-2.3.0/gems/activerecord-4.2.7.1/lib/active_record/relation/finder_methods.rb:280:in `exists?\'', 'app/models/a.rb:23', 'app/models/b.rb:42'])
    assert_equal [{ 'message' => 'deprecated call', 'callstack' => 'app/models/a.rb:23' }], YAML.safe_load(writer.contents)
  end

  def test_contents_new_file_is_array
    assert_equal [], YAML.safe_load(new_writer('').contents)
  end

  def test_contents_sorting
    writer = new_writer
    writer.add('deprecated call 1', ['app/models/a.rb:42', 'app/models/b.rb:42'])
    writer.add('deprecated call 2', ['app/models/a.rb:23', 'app/models/b.rb:42'])
    writer.add('deprecated call 1', ['app/models/a.rb:23', 'app/models/b.rb:42'])
    assert_equal [
      { 'message' => 'deprecated call 1', 'callstack' => 'app/models/a.rb:23' },
      { 'message' => 'deprecated call 1', 'callstack' => 'app/models/a.rb:42' },
      { 'message' => 'deprecated call 2', 'callstack' => 'app/models/a.rb:23' }
    ], YAML.safe_load(writer.contents)
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
