DevScripts::Script.define_script :rubocop_metrics_method_length do
  class RubocopMetricsMethodLength
    class MethodReader
      class Line
        attr_reader :line, :index

        def initialize(line, index)
          @line = line
          @index = index
        end

        def opening?
          line =~ /def \w/
        end

        def closing?
          line =~ /\A\s*end(\n)*/
        end

        def to_s
          line
        end

        def indentation
          line.scan(/\A\s*/).first
        end
      end

      attr_reader :to_s

      def initialize(file_path, line_number)
        @file_path = file_path
        @line_number = line_number
        @block_openings = []
        @block_closings = []
        @all_lines = []

        File.foreach(@file_path).with_index do |line, index|
          next if index + 1 < line_number

          next if reached_method_end?

          wrapped_line = Line.new(line, index)

          @block_openings << wrapped_line if wrapped_line.opening?
          @block_closings << wrapped_line if wrapped_line.closing?
          @all_lines << wrapped_line
        end

        @to_s = all_lines.map(&:to_s).join('')
      end

      def first_line
        all_lines.first.index
      end

      def last_line
        all_lines.last.index
      end

      def indentation
        all_lines.first.indentation
      end

      private

      attr_reader :all_lines

      def reached_method_end?
        return false if @block_openings.size.zero? || @block_closings.size.zero?

        @block_openings.size == @block_closings.size
      end
    end

    def initialize(file_path, line_number)
      @file_path = file_path

      @line_number = line_number.to_i
      @all_lines = []

      File.foreach(file_path) { |line| @all_lines << line }
    end

    def method_text
      @method_text ||= method_reader.to_s
    end

    def method_reader
      @method_reader ||= MethodReader.new(file_path, line_number)
    end

    def run
      all_lines.insert(
        method_reader.first_line,
        "#{method_reader.indentation}# rubcop:disable Metrics/MethodLength\n"
      )

      all_lines.insert(
        method_reader.last_line + 2,
        "#{method_reader.indentation}# rubcop:enable Metrics/MethodLength\n"
      )

      File.open(file_path, 'w') { |file| file.write(all_lines.join('')) }
    end

    private

    attr_reader :line_number, :file_path, :all_lines
  end

  args :file_path, :line_number
  
  execute do
    RubocopMetricsMethodLength.new(file_path, line_number).run
  end
end
