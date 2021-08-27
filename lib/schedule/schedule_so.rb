module Schedule
  class ScheduleSO 
    def initialize(so)
      @so = so
    end

    def print_to_console
      print_header(@so)
      print_lines(@so)
    end

    def exists?
      check_exists(@so.so_num.to_s)
    end

    def warn_exists
      puts "Sales Order #{@so.so_num} already exists in the scheduling database.".white.on_red.bold
    end

    def push
      push_to_shazam(@so)
    end

    private

    def print_header(so)
      print "\n" if SalesOrder.iteration > 1
      puts "------!> #{so.so_num} ".yellow.bold +
           "for #{so.ship_to_name} ".green +
           "(#{so.customer_po_num}) shipping ".green +
           "#{so.requested_ship_date}".yellow +
           ($opts.test ? "     " + "!!TEST RUN ONLY!!".white.on_red.bold : "")
    end

    def print_lines(so)
      so.layup_lines.lines.each do |ln|
        puts "           #{ln.part_num} ".cyan +
          "#{Schedule::Constants::SIZE[ln.size][:inches]}, ".cyan +
          "#{ln.qty}, #{ln.face.code} (#{ln.face.bin} - #{ln.face.qty_on_hand}), ".cyan +
          "#{ln.back.code} (#{ln.back.bin} - #{ln.back.qty_on_hand}), ".cyan +
          "#{ln.thick}, ".cyan +
          "#{ln.core.codes*' + '}".cyan
      end
    end

    def check_exists(so_num)
      Schedule::DBs::DB_SCHED.fetch(Schedule::Queries::SHAZ_SO_EXISTS, so_num).count >= 1
    end

    def push_to_shazam(so)
      shaz_insert_header(so.so_num, so.ship_to_name, so.customer_po_num,
                         so.requested_ship_date, so.customer_num, so.address1,
                         so.address2, so.city, so.state, so.zipcode, Time.now.strftime('%F %T'))
      @job_id = job_id
      so.layup_lines.lines.each do |ln|
        shaz_size = Schedule::Constants::SIZE[ln.size][:shazam]
        shaz_comp, shaz_exclude = 0, 0
        shaz_comment = ln.line_num.to_s + '.' + ln.face.instructions + ln.core.instructions
        shaz_line = "L#{ln.line_num.to_i.to_s.rjust(3, '0')}"
        po_face = ''
        po_back = ''
        po_date = if ln.face.po.date || ln.back.po.date
                    "\##{[ln.face.po.date.to_s, ln.back.po.date.to_s].max}\#"
                  else
                    'NULL'
                  end
        lu_date = "\##{Schedule::Utils.shift_business_day(so.requested_ship_date, -1).strftime("%F")}\#"
        lu_ship_date = "\##{Schedule::Utils.shift_business_day(so.requested_ship_date, 0).strftime("%F")}\#"

        shaz_insert_detail(@job_id, shaz_size, ln.qty, ln.face.code, ln.thick,
                           ln.core.codes*' + ', ln.back.code, shaz_comment, shaz_line,
                           ln.face.po.number, ln.back.po.number, po_date, lu_date, lu_ship_date, 
                           shaz_comp, shaz_exclude, ln.face.bin, ln.back.bin,
                           ln.wo_num, ln.wt_num, ln.face.desc1, ln.face.desc2,
                           ln.back.desc1, ln.back.desc2, ln.part_num, ln.desc1,
                           ln.desc2, ln.face.prodcat, ln.back.prodcat, ln.weight,
                           ln.face.weight, ln.back.weight, ln.core.weight, ln.customer_pn)
        update_notes(ln.wo_num)
      end
    end

    def update_notes(wo_num)
      Schedule::DBs::DB_SCHED.run(
      "UPDATE tblJobs
         SET JobHistory = JobHistory  & \'wo#{wo_num} \'
         WHERE JobID=#{@job_id}")
    end

    def shaz_insert_header(so_num, cust, cust_po, shipdate, customer_num,
                           address1, address2, city, state, zipcode, date_time_now)
      if $opts.debug
        ap "VALUES (\'#{so_num}\', \'#{cust}\', \'#{cust_po}\', \'#{shipdate}\', \'#{shipdate}\', FALSE, 2,
                \'#{customer_num}\', \'#{address1}\', \'#{address2}\', \'#{city}\',
                \'#{state}\', \'#{zipcode}\'  \'#{cust_po}\')"
      end
      return if ($opts.debug || $opts.test)
      Schedule::DBs::DB_SCHED.run(
      "INSERT INTO tblJobs (JobSalesOrderNo, JobCustomer, JobDescription,
                           JobShipDate, JobShipDateOriginal, JobLayupCompleted,
                           JobLocation, CustomerNO, ShipToAddress1, ShipToAddress2,
                           ShipToCity, ShipToState, ShipToZipCode, CustomerPO, JobEnteredDateTime)
      VALUES (\'#{so_num}\', \'#{cust}\', \'#{cust_po}\', \'#{shipdate}\', \'#{shipdate}\', FALSE, 2,
              \'#{customer_num}\', \'#{address1}\', \'#{address2}\', \'#{city}\',
              \'#{state}\', \'#{zipcode}\',  \'#{cust_po}\', \'#{date_time_now}\')")
    end

    def shaz_insert_detail(job, shaz_size, qty, top, thick,
                           core, bottom, shaz_comment, shaz_line,
                           po_face, po_back, po_date, lu_date, lu_ship_date,
                           shaz_comp, shaz_exclude, face_bin, back_bin,
                           wo_num, wt_num, face_desc1, face_desc2,
                           back_desc1, back_desc2, fg_part_num, fg_desc1,
                           fg_desc2, face_prodcat, back_prodcat, fg_weight,
                           face_weight, back_weight, core_weight, customer_pn
                          )
      if $opts.debug
        ap "VALUES (#{job}, #{shaz_size}, \'#{qty}\', \'#{top}\', \'#{thick}\',
          \'#{core}\', \'#{bottom}\', \'#{shaz_comment}\', \'#{shaz_line}\',
          \'#{po_face}\', \'#{po_back}\', #{po_date}, #{lu_date}, #{lu_ship_date},
            #{shaz_comp}, #{shaz_exclude}, \'#{face_bin}\', \'#{back_bin}\',
          \'#{wo_num}\', \'#{wt_num}\', \'#{face_desc1}\', \'#{face_desc2}\',
          \'#{back_desc1}\', \'#{back_desc2}\', \'#{fg_part_num}\', \'#{fg_desc1}\',
          \'#{fg_desc1}\', \'#{face_prodcat}\', \'#{back_prodcat}\', \'#{fg_weight}\',
          \'#{face_weight}\', \'#{back_weight}\', \'#{core_weight}\', \'#{customer_pn}\' )"
      end
      return if ($opts.debug || $opts.test)
      Schedule::DBs::DB_SCHED.run(
      "INSERT INTO tblLayupItems
        (JobID, LayupSizeID, LayupQnty, LayupTOP, LayupCoreThk,
         LayupCoreMatl, LayupBOTTOM, LayupInstructions, LayupStagerNote,
         LayupPO, LayupPO2, LayupPORxOverride, LayupGlueOverride, ShipDate,
         LayupComponent, LayupExclude, InforBinTop, InforBinBot,
         WoNumber, WtNumber, TopDesc1, TopDesc2,
         BotDesc1, BotDesc2, FGPartNum, FGPartDesc1,
         FGPartDesc2, ProdcatTop, ProdcatBot, FGPartWeight,
         TopWeight, BotWeight, LayupCoreSumWeight, LabelInfoSupplimental)
      VALUES (#{job}, #{shaz_size}, \'#{qty}\', \'#{top}\', \'#{thick}\',
            \'#{core}\', \'#{bottom}\', \'#{shaz_comment}\', \'#{shaz_line}\',
            \'#{po_face}\', \'#{po_back}\', #{po_date}, #{lu_date}, #{lu_ship_date},
              #{shaz_comp}, #{shaz_exclude}, \'#{face_bin}\', \'#{back_bin}\',
            \'#{wo_num}\', \'#{wt_num}\', \'#{face_desc1}\', \'#{face_desc2}\',
            \'#{back_desc1}\', \'#{back_desc2}\', \'#{fg_part_num}\', \'#{fg_desc1}\',
            \'#{fg_desc1}\', \'#{face_prodcat}\', \'#{back_prodcat}\', \'#{fg_weight}\',
            \'#{face_weight}\', \'#{back_weight}\', \'#{core_weight}\', \'#{customer_pn}\' )")
    end

    def job_id
      Schedule::DBs::DB_SCHED.fetch("SELECT MAX(JobID) AS JobID FROM tblJobs").first[:JobID]
    end
  end
end
