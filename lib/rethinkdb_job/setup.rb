class RethinkDBJob
  module Setup
    def rql_db_string(rql_db)
      rql_db.instance_variable_get("@body")[1].first
    end

    def database
      # ugly hack until @rdb.default_db works properly
      db = rdb.instance_variable_get("@default_opts")[:db]
      if db
        rql_db_string(db)
      else
        @rdb_config[:db] || "test"
      end
    end

    def done_setup?
      @done_setup
    end

    def ensure_setup
      unless done_setup?
        setup
        @done_setup = true
      end
    end

    def setup
      begin
        rdb
      rescue => e
        msg = "cannot connect to RethinkDB #{@rdb_config.inspect}"
        raise e.class, e.message + ", #{msg}", caller
      end

      begin
        r.db_create(database).run(rdb)
      rescue RethinkDB::RqlRuntimeError => err
        # already exists, cool
      rescue => e
        msg = "cannot create db #{database.inspect}"
        raise e.class, e.message + ", #{msg}", caller
      end

      begin
        r.db(database).table_create(table).run(rdb)
      rescue RethinkDB::RqlRuntimeError => err
        # already exists, cool
      rescue => e
        msg = "cannot create table #{table.inspect} on database #{database.inspect}"
        raise e.class, e.message + ", #{msg}", caller
      end
    end
  end
end