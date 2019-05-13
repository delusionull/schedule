require_relative 'options'
require_relative 'dbs'
require_relative 'utils'
require_relative 'constants'
require_relative 'queries'
require_relative 'pos'
require_relative 'sales_order'
require_relative 'schedule_so'

class NilClass
  def method_missing(*a)
    nil
  end
end

module Schedule
  class Runner
    def initialize()
      $opts = Options.new()
    end

    def run
      sos = $opts.all_sos ? get_all_sos : $opts.sos
      $pos = Schedule::Pos.new.pos
      sos.each do |so_num|
        so = SalesOrder.new(so_num)
        next so.skip_message if so.skip
        schedule_so = ScheduleSO.new(so)
        #puts "after ScheduleSO instantiation: #{Time.now}"
        schedule_so.print_to_console
        #puts "after ScheduleSO print: #{Time.now}"
        if schedule_so.exists?
          schedule_so.warn_exists
          next unless ($opts.debug || $opts.test)
        end
        #puts "after ScheduleSO exists: #{Time.now}"
        schedule_so.push
        #puts "after ScheduleSO push: #{Time.now}"
      end
    end

    private

    def get_all_sos
      Schedule::DBs::DB_INFOR.fetch(Schedule::Queries::ALL_SO_NUMS).map do |x|
        x[:sales_order].to_s
      end
    end
  end
end

