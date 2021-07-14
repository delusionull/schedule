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
      @lines.each{|l| return true if l[:com_part_num].upcase.start_with?('MDO')}
      @lines.each{|l| return true if l[:com_part_num].upcase.start_with?('PLY') &&
                                    !l[:com_part_num].upcase.include?('MDF') &&
                                    !l[:com_part_num].upcase.include?('BALTIC') &&
                                    !l[:com_part_num].upcase.include?('ACFIR')}
      @lines.each{|l| return true if l[:part_num].upcase.start_with?('FORBO')}
      @pn_info[:core] == 'DO'
    end

    def backer204
      @pn_info[:back] == 'BL' ||
      @pn_info[:face] == 'BL'
    end

    def customer_core
      @pn_info[:core] == 'ZZ' ||
      @pn_info[:core] == 'CUST'
    end

    def core_last_line
      cll = @lines.find_all{|h| Schedule::Constants::CORE_CODES.member?(h[:prod_detail][0..1]) }
            .max_by{|h| h[:sequence_num] }[:sequence_num].to_i
      return 0 if customer_core && cll == 0
      core = @lines.find{|h| h[:product_category] == 'LARB'}
      raise "Core code bin for core: #{core[:com_part_num]} not set up in ICSW".white.on_red.bold if cll == 0
      return cll
    end
  end
end

