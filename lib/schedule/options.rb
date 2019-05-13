require 'optimist'

module Schedule
  class Options
    attr_reader :test, :sos, :all_sos, :debug

    def initialize()
      opts = Optimist::options do
        banner "Usage:"
        banner "#{File.basename($0)} [-t] (-a | -s <sales_order> [<sales_order>] ...)"
        banner "\nOptions:"

        opt :test, "Test run only; don't commit changes."
        opt :all_sales_orders, "Process all sales orders which are ready."
        opt :sales_orders, "Sales orders to process.", { :type => :strings }
        opt :debug, "(not implemented)\nRun in debug mode; display helpful output.     "
        opt :verbosity,
          "(not implemented)\nVerbosity of output:\n" +
          "  0 (none)\n  1 (normal)\n  2 (verbose)\n  3 (very verbose)\n",
          :type => :int,
          :default => 1
        opt :update, "(not implemented)\nUpdate an existing sales order."
        opt :delete, "(not implemented)\nDelete an existing sales order."

        conflicts( :all_sales_orders, :sales_orders )
      end
      Optimist::educate unless (opts[:test] || opts[:all_sales_orders] || opts[:sales_orders])

      @test = opts[:test]
      @sos = opts[:sales_orders]
      @all_sos = opts[:all_sales_orders]
      @debug = opts[:debug]
    end
  end
end

