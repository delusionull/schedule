module Schedule
  class PanelConfig
    def initialize(lines, pn_info)
      @lines = lines
      @pn_info = pn_info
    end

    def rawface
      @pn_info[:back] == 'RA' ||
      @pn_info[:face] == 'RA'
    end

    def rawback
      @pn_info[:face] == 'RA' &&
      @pn_info[:back] == 'G2'
    end

    def facedown
      @pn_info[:orientation] == 'D'
    end

    def g2s
      @pn_info[:back] == 'G2'
    end

    def frglue
      @pn_info[:core][1] == 'F'
    end

    def metalglue
      @pn_info[:core] == 'DO'
    end

    def core_last_line
      return 0 if customer_core
      cll = @lines.find_all{|h| Schedule::Constants::CORE_CODES.member?(h[:prod_detail][0..1]) }
            .max_by{|h| h[:sequence_num] }[:sequence_num].to_i
      raise "Core code not in list or lines out of order" if cll == 0
      return cll
    end

    private

    def customer_core
      @pn_info[:core] == 'CUST'
    end
  end
end

