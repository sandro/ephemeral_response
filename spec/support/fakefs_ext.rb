module FakeFS
  class Dir
    class << self
      alias glob_without_block glob

      def glob(pattern, &block)
        ary = glob_without_block(pattern)
        ary.each &block if block_given?
        ary
      end
    end
  end
end

