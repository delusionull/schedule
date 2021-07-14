require_relative 'layup_lines'

module Schedule
  class SalesOrder
    attr_reader :so_num
    @@iteration = 0

    def initialize(so_num)
      @so_qry_lines = $sos.select { |line| line[:sales_order] == so_num }
      @so_num = so_num
      @@iteration += 1
    end

    def self.iteration
      @@iteration
    end

    def so_suffix
      @so_qry_lines.first[:suffix]
    end

    def customer_po_num
      (@so_qry_lines.first[:customer_po_num].strip).gsub(/[^\w ]/, '')
    end

    def ship_to_name
      (@so_qry_lines.first[:ship_to_name]).gsub(/[^&\w]+/, ' ').strip
    end

    def customer_num
      @so_qry_lines.first[:customer_num]
    end

    def address1
      (@so_qry_lines.first[:address1]).gsub(/[^\w]+/, ' ').strip
    end

    def address2
      (@so_qry_lines.first[:address2]).gsub(/[^\w]+/, ' ').strip
    end

    def city
      (@so_qry_lines.first[:city]).gsub(/[^\w]+/, ' ').strip
    end

    def state
      @so_qry_lines.first[:state]
    end

    def zipcode
      @so_qry_lines.first[:zip]
    end

    def requested_ship_date
      @so_qry_lines.first[:requested_ship_date].strftime('%F')
    end

    def layup_lines
      LayupLines.new(@so_qry_lines)
    end

    def weight
      sum = 0
      layup_lines.lines.each{|ln| sum += ln.weight}
      return sum
    end

    def skip
      ( skip_not_found || skip_lines_not_conseq ) ? true : false
    end

    private

    def skip_not_found
      if @so_qry_lines.count < 1
        puts "Skipping #{@so_num}. Order not found in Infor DB".white.on_red.bold
        true
      else
        false
      end
    end

    def skip_lines_not_conseq
      if non_conseq(@so_qry_lines)
        ap @so_qry_lines if $opts.debug
        puts "Skipping #{@so_num}. Order lines are not consecutive".white.on_red.bold
        true
      else
        false
      end
    end

    def non_conseq(lns)
      ln_nos = lns.map{|x| x[:ord_line_num]}.uniq
      ln_nos.max === ln_nos.length ? false : true
    end
  end
end

