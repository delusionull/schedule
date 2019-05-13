require 'oci8'
require 'sequel'
require_relative 'credentials'

module Schedule
  module DBs
    # https://github.com/kubo/ruby-oci8/issues/28
    OCI8::BindType::Mapping[Time] = OCI8::BindType::LocalTime
    OCI8::BindType::Mapping[:date] = OCI8::BindType::LocalTime

    TEST = 'NO'

    INFOR_DB   = '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)' +
                   "(HOST=#{TEST == 'YES' ? '***REMOVED***' : '***REMOVED***'}" +
                   ')(PORT=***REMOVED***))(CONNECT_DATA=(SID=' +
                   "#{TEST == 'YES' ? '***REMOVED***' : '***REMOVED***'})))"

    DB_INFOR = Sequel.connect(adapter: 'oracle',
                              user: Schedule::Credentials::USR,
                              password: Schedule::Credentials::PWD,
                              database: INFOR_DB)

    SCHED_PATH = 'W:\\shazam\\Schedule Shazam Dal_NEW.mdb'

    connection_string = 'Provider=Microsoft.ACE.OLEDB.12.0;Data Source='
    DB_SCHED = Sequel.ado(:conn_string=>connection_string + SCHED_PATH) 
  end
end

