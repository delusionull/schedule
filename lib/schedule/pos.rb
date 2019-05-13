module Schedule
  class Pos
    def initialize
      @pos = pos
    end

    def pos
      Schedule::DBs::DB_INFOR.fetch(Schedule::Queries::POS_QRY_STR).all
    end
  end
end

