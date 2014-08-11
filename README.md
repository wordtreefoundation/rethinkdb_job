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
data = job.find(job_id)
# => {
#   "id" => "9f8c8831-3e31-4366-a91c-aa2e1d1c8d4b",
#   "job_start"=>2014-08-10 00:00:00 -0600
# }
```
