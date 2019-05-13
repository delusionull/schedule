module Schedule
  class Po
    attr_reader :number, :date

    def initialize(wo_num, material_code, prodcat)
      @po_info = $pos.find { |h| h[:wo_num] == wo_num; h[:prod_code] == material_code }
      @number = number
      @date = date
      @pc = prodcat
    end

    def number
      return '' if not_laminate
      @po_info[:po_num]&.to_i || 'STOCK'
    end

    def date
      @po_info[:exp_date]&.strftime('%F')
    end

    private

    def not_laminate
      (@pc == 'ILSH' || @pc == 'BKSH' || @pc == 'LALN' || @pc == 'LARB' || @pc == '')
    end
  end
end
