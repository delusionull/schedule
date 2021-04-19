require 'oci8'
require 'sequel'
require_relative 'credentials'

module Schedule
  module DBs
    # https://github.com/kubo/ruby-oci8/issues/28
    OCI8::BindType::Mapping[Time] = OCI8::BindType::LocalTime
    OCI8::BindType::Mapping[:date] = OCI8::BindType::LocalTime

    TEST = 'NO'

    INFOR_DB =
      '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)' +
      "(HOST=#{TEST == 'YES' ? Schedule::Credentials::TESTHOST : Schedule::Credentials::HOST}" +
      ')(PORT=' + Schedule::Credentials::PORT.to_s + '))(CONNECT_DATA=(SID=' +
      "#{TEST == 'YES' ? Schedule::Credentials::TESTSID : Schedule::Credentials::SID})))"

    DB_INFOR = Sequel.connect(
      adapter: 'oracle',
      user: "#{TEST == 'YES' ? Schedule::Credentials::TESTUSR : Schedule::Credentials::USR}",
      password: "#{TEST == 'YES' ? Schedule::Credentials::TESTPWD : Schedule::Credentials::PWD}",
      database: INFOR_DB
    )

    SCHED_PATH = 'Z:\\Schedule Shazam Dal_NEW.mdb'

    connection_string = 'Provider=Microsoft.ACE.OLEDB.12.0;Data Source='
    DB_SCHED = Sequel.ado(:conn_string=>connection_string + SCHED_PATH) 
  end
end

