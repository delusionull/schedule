require_relative 'po'

module Schedule
  class Laminate
    def initialize(lines, panel_config)
      @lines = lines
      @panel_config = panel_config
    end

    def code
      return 'RAW' if raw
      @lines.find { |h| h[:sequence_num] == line_num }[:com_part_num]
    end

    def bin
      return '' if nobin
      material ? material[:prod_bin] : 'NOT_FOUND'
    end

    def qty_on_hand
      material ? material[:prod_qty_on_hand].to_i : 0
    end

    def po
      Schedule::Po.new(get_wonum, code, prodcat)  # material_code will be passed in here
    end

    def prodcat
      return '' if @panel_config.rawface
      @lines.find { |h| h[:sequence_num] == line_num }[:product_category]
    end

    def desc1
      material ? material[:prod_desc1].gsub(/[^\w ]/, '') : ''
    end

    def desc2
      material ? material[:prod_desc2].gsub(/[^\w ]/, '') : ''
    end

    def instructions
      get_lam_instructions
    end

    private

    def material
      Schedule::DBs::DB_INFOR.fetch(Schedule::Queries::PROD_QRY_STR, code).first
    end

    def line_num
      @panel_config.core_last_line + (@panel_config.facedown || @panel_config.g2s ? 1 : 2)
    end

    def get_wonum
      if @lines[0][:wo_num] > 0
        @lines[0][:wo_num]
      elsif @lines[0][:wt_num] > 0
        @lines[0][:wt_num]
      else
        0
      end
    end

    # this is to poll 'bin2' to determine if a material is liner/backer/resin
    def material_code(prod)
      Schedule::DBs::DB_INFOR.fetch(Schedule::Queries::PROD_QRY_STR, prod).first[:prod_detail][0..1]
    end

    def get_lam_instructions
      text = ''
      text << " *RAW 1 SIDE*" if raw
      return text
    end
  end

  class Face < Laminate
    private

    def line_num
      #@panel_config.core_last_line + (@panel_config.facedown || @panel_config.g2s ? 1 : 2)
      @panel_config.core_last_line + (@panel_config.facedown ? 1 : 2)
    end

    def raw
      @panel_config.rawface
    end
    
    alias_method :nobin, :raw
  end

  class Back < Laminate
    private

    def line_num
      @panel_config.core_last_line + (@panel_config.facedown ? 2 : 1)
    end

    def raw
      @panel_config.rawback
    end
    
    alias_method :nobin, :raw
  end
end

