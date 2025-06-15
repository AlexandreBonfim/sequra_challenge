require "csv"
require "ruby-progressbar"
require "benchmark"

module Importers
  class BaseImporter
    attr_reader :path, :batch_size

    def initialize(path:, batch_size: 1000)
      @path = path
      @batch_size = batch_size
    end

    def import
      puts "📥 Importing #{model_name} from #{path}"

      time = Benchmark.measure do
        process_csv
      end

      puts "✅ #{model_name} imported in #{time.real.round(2)} seconds"
    end

    protected

    def process_csv
      rows = []
      current_time = Time.current
      progress = create_progress_bar

      CSV.foreach(path, headers: true, col_sep: ";") do |row|
        process_row(row, rows, current_time)
        progress.increment
      end

      insert_remaining_rows(rows) if rows.any?
    end

    def process_row(row, rows, current_time)
      # To be implemented by subclasses
      raise NotImplementedError
    end

    def insert_remaining_rows(rows)
      model.insert_all!(rows, returning: false) if rows.any?
    end

    def create_progress_bar
      total_lines = `wc -l "#{path}"`.split.first.to_i - 1 # minus header line
      ProgressBar.create(
        title: "Importing #{model_name}",
        total: total_lines,
        format: "%t |%B| %c/%C"
      )
    end

    def model
      # To be implemented by subclasses
      raise NotImplementedError
    end

    def model_name
      model.name.pluralize
    end
  end
end
