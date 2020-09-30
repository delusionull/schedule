require_relative 'core'
require_relative 'laminate'
require_relative 'panel_config'

module Schedule
  class LayupLine
    def initialize(lines)
      @lines = lines
      @part_num = part_num
      @pn_info = pn_info || prompt_for_pn_info
      @panel_config = panel_config
    end

    def part_num
      @lines[0][:part_num]
    end

    def wo_num
      (@lines[0][:wo_num].to_s + @lines[0][:wo_suffix].to_s.rjust(2, "0")).to_i
    end

    def wt_num
      @lines[0][:wt_num].to_i
      #(@lines[0][:wt_num].to_s + @lines[0][:wt_suffix].to_s.rjust(2, "0")).to_i
    end

    def qty
      @lines[0][:wo_line_qty].to_i
    end

    def line_num
      @lines[0][:ord_line_num]
    end

    def thick
      Schedule::Constants::THICK[@pn_info[:thick]][:decimal]
    end

    def size
      size = @pn_info[:size]
      #raise "No panel size info found. Check FG part number." unless size
      return size
    end

    def core
      Core.new(@lines, @panel_config)
    end

    def face
      Face.new(@lines, @panel_config)
    end

    def back
      Back.new(@lines, @panel_config)
    end

    def weight
      @lines[0][:fg_weight].to_i
    end

    def desc1
      @lines[0][:fg_desc1].gsub(/[^\w ]/, '')
    end

    def desc2
      @lines[0][:fg_desc2].gsub(/[^\w ]/, '')
    end

    def customer_pn
      /\!~(.+?)( |$)/.match(@lines[0][:ord_line_comment]).to_a[1].to_s
    end

    private

    def panel_config
      PanelConfig.new(@lines, @pn_info)
    end

    def pn_info
      ap @part_num
      return afi_pn_info if @part_num[0..1] == '0-'
      return cust_pn_info if /CUST/.match(@part_num)
      /
      (?<vend>(#{Schedule::Constants::VEND.keys*'|'})?)        # the laminate vendor indicator
      (?<face>(#{Schedule::Constants::FACE_CODES*'|'}|.{3}.*)) # the face code
      (?<core>#{Schedule::Constants::CORE_CODES*'|'})          # the two digit core code
      (?<thick>[0-5]\d)                                        # the panel thickness
      (?<back>(#{Schedule::Constants::BACK_CODES*'|'}|.{4}.*)) # the two digit back code
      (?<size>#{Schedule::Constants::SIZE.keys*'|'})           # the two digit size code
      (?<orientation>[UD]?)                                    # the panel orientation
      /x.match(@part_num)
    end

    def afi_pn_info
      thick = /0-.*-.*-([0-5]\d)/.match(@part_num)[1]
      afi_size = /0-.*-.*-[0-5]\d(#{Schedule::Constants::AFI_INFOR_SIZE.keys*'|'})/.match(@part_num)[1]
      size = Schedule::Constants::AFI_INFOR_SIZE[afi_size]
      back = /SAME/.match(@part_num) ? 'G2' : ''
      return {:thick => thick, :size => size, :back => back, :face => '', :core => '' }
    end

    def cust_pn_info
      info =
      /
      (?<vend>(#{Schedule::Constants::VEND.keys*'|'})?)        # the laminate vendor indicator
      (?<face>(#{Schedule::Constants::FACE_CODES*'|'}|.{3}.*)) # the face code
      (?<core>#{Schedule::Constants::CORE_CODES*'|'})          # the two digit core code
      (?<thick>([0-5]\d)?)                                     # the panel thickness
      (?<back>(#{Schedule::Constants::BACK_CODES*'|'}|.{4}.*)) # the two digit back code
      (?<size>#{Schedule::Constants::SIZE.keys*'|'})           # the two digit size code
      (?<orientation>[UD]?)                                    # the panel orientation
      /x.match(@part_num)
      thick = info[:thick] || '00'
      return {:thick => thick,
              :size => info[:size],
              :back => info[:back],
              :face => info[:face],
              :core => info[:core],
              :orientation => info[:orientation] }
    end

    def prompt_for_pn_info
      puts "Cannot parse info from non-typical part number: #{@part_num}"
      puts "Please manually input required data."
      puts Schedule::Constants::THICK.keys*', '
      thick = Utils.prompt "Enter panel thickness in mm: "
      puts Schedule::Constants::CORE_CODES*', '
      core = Utils.prompt "Enter panel core code: "
      puts Schedule::Constants::SIZE.keys*', '
      size = Utils.prompt "Enter panel size code: "
      return {:thick => thick,
              :size => size.to_s.upcase,
              :back => back.to_s.upcase,
              :face => face.to_s.upcase,
              :core => core.to_s.upcase}
    end
  end
end

