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
      $sos = $opts.all_sos ? get_all_sos : get_specific_sos
    end

    def run
      sos = get_so_nums
      $pos = Schedule::Pos.new.pos
      sos.each do |so_num|
        so = SalesOrder.new(so_num.to_i)
        next if so.skip
        schedule_so = ScheduleSO.new(so)
        schedule_so.print_to_console
        if schedule_so.exists?
          schedule_so.warn_exists
          next unless ($opts.debug || $opts.test)
        end
        puts ''
        schedule_so.push
      end
    end

    private

    def get_all_sos
      Schedule::DBs::DB_INFOR.fetch(Schedule::Queries::ALL_SOS).all
    end

    def get_specific_sos
      Schedule::DBs::DB_INFOR.fetch(Schedule::Queries::SPECIFIC_SOS, $opts.sos, $opts.sos).all
    end

    def get_so_nums
      $opts.all_sos ? $sos.map { |x| x[:sales_order] }.uniq : $opts.sos
      end
    end
  end
end

