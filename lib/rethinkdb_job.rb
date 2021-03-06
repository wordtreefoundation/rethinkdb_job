require 'rethinkdb'
require 'rethinkdb_job/setup'

class RethinkDBJob
  attr_reader :table, :r

  include RethinkDBJob::Setup

  def initialize(rdb_config={})
    @rdb_config = rdb_config
    @table = @rdb_config.delete(:table) || "jobs"
    @done_setup = false

    @r = RethinkDB::RQL.new
  end

  def rdb
    @rdb ||= @r.connect(@rdb_config)
  end

  def create
    ensure_setup
    result = @r.table(@table).insert({}, :return_changes => true).run(rdb)
    if result["inserted"] == 1
      change = result["changes"].first
      change["new_val"]["id"]
    else
      raise "Unable to create new job record"
    end
  end

  def find(job_id)
    @r.table(@table).get(job_id).run(rdb)
  end

  TIMESTAMP_COLUMNS = [:job_start, :job_finish]
  def set_timestamp(job_id, column, time=Time.now)
    ensure_setup
    if TIMESTAMP_COLUMNS.include?(column.to_sym)
      @r.table(@table).get(job_id).update(column => time).run(rdb)
      time
    else
      raise "expected column to be one of #{timestamp_columns.inspect} (#{column.inspect})"
    end
  end

  def logdir
    raise "RethinkDBJob :logdir not set" if @rdb_config[:logdir].nil?
    @rdb_config[:logdir]
  end
  
  def logfile(job_id)
    File.join(logdir, "job_#{job_id}.log")
  end

  def tail(job_id, lines=10)
    `tail -#{Integer(lines).to_s} #{logfile(job_id)} 2>&1`
  end
end