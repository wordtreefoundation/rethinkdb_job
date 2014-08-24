require_relative '../spec_helper'

UUID_RE = /[a-z0-9]{8,8}-[a-z0-9]{4,4}-[a-z0-9]{4,4}-[a-z0-9]{4,4}-[a-z0-9]{12,12}/

describe RethinkDBJob do
  it "initializes" do
    RethinkDBJob.new
  end

  it "can access the default_db" do
    job = RethinkDBJob.new
    expect(job.database).to eq("test")

    job = RethinkDBJob.new(:db => "test2")
    expect(job).to receive(:rql_db_string).with(any_args).and_call_original
    expect(job.database).to eq("test2")
  end

  it "should not be done setup at first" do
    job = RethinkDBJob.new
    expect(job.done_setup?).to eq(false)
  end

  it "can configure the logdir" do
    job = RethinkDBJob.new(:logdir => "test")
    expect(job.logdir).to eq("test")
  end

  describe "#logfile" do
    it "joins" do
      job = RethinkDBJob.new(:logdir => "/test")
      expect(job.logfile("xyz")).to eq("/test/job_xyz.log")
    end
    
    it "converts integer job IDs to string" do
      job = RethinkDBJob.new(:logdir => "/test")
      expect(job.logfile(123)).to eq("/test/job_123.log")
    end
  end

  describe "#tail" do
    it "tails last 10 lines of a file" do
      job = RethinkDBJob.new(:logdir => "/tmp")
      File.open("/tmp/job_tail.log", "w") do |f|
        f.write("1\n2\n3\n")
      end
      expect(job.tail("tail")).to eq("1\n2\n3\n")
    end
  end

  context "given a RethinkDBJob instance" do
    let(:job) { RethinkDBJob.new }

    it "create a job" do
      expect(job.create).to match(UUID_RE)
    end

    it "finds a job" do
      job_id = job.create
      expect(job_id).to match(UUID_RE)
      assigned_time = Time.new(2014, 8, 10)
      job.set_timestamp(job_id, :job_start, assigned_time)
      job_obj = job.find(job_id)
      expect(job_obj).to eq(
        "id" => job_id,
        "job_start" => assigned_time
      )
    end

    it "sets timestamp" do
      job_id = job.create
      expect(job_id).to match(UUID_RE)
      assigned_time = Time.new(2014, 8, 10)
      returned_time = job.set_timestamp(job_id, :job_start, assigned_time)
      expect(returned_time).to eq(assigned_time)
    end

    context "with empty db" do
      before do
        begin
          job.r.table_drop("jobs").run(job.rdb)
        rescue RethinkDB::RqlRuntimeError
        end
      end

      it "sets up the database" do
        expect { job.r.table("jobs").count.run(job.rdb) }.to raise_error
        job.setup
        expect { job.r.table("jobs").count.run(job.rdb) }.to_not raise_error
      end
    end
  end
end