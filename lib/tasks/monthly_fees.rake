namespace :monthly_fees do
  desc "Calculate monthly fees for all merchants for a given month"
  task calculate: :environment do
    year = ENV["YEAR"]&.to_i
    month = ENV["MONTH"]&.to_i

    unless year.positive? && (1..12).include?(month)
      puts "❌ Please provide YEAR and MONTH. Example:"
      puts "   rails monthly_fees:calculate YEAR=2024 MONTH=5"
      exit 1
    end

    puts "📊 Calculating monthly fees for #{year}-#{month.to_s.rjust(2, '0')}..."
    time = Benchmark.measure do
      MonthlyFeeCalculator.call(year: year, month: month)
    end

    puts "✅ Done in #{time.real.round(2)} seconds"
  end
end
