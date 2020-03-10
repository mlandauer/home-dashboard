require 'influxdb2/client'

client = InfluxDB2::Client.new(
  ENV["INFLUXDB_URL"],
  ENV["INFLUXDB_TOKEN"]
)
bucket = ENV["INFLUXDB_BUCKET"]
org = ENV["INFLUXDB_ORG"]

SCHEDULER.every '5s' do
  query = "from(bucket: \"#{bucket}\") |> range(start: -2h) |> filter(fn: (r) => r._measurement == \"solar\") |> filter(fn: (r) => r._field == \"soc\") |> last()"
  tables = client.create_query_api.query(query: query, org: org)

  send_event('stateofcharge',   { value: tables[0].records[0].value })
end
