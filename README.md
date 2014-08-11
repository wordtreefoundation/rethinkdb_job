# RethinkDBJob

A simple model that tracks job information in RethinkDB for api-scripts. Used in conjunction with beanstalkd (but not strictly required as a dependency).

## Usage

```ruby
require 'rethinkdb_job'

job = RethinkDBJob.new

job_id = job.create

job.set_timestamp(job_id, :job_start)
```

Find a job:

```ruby
job.find(job_id)
```
