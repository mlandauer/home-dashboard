require 'influxdb2/client'

client = InfluxDB2::Client.new(
  ENV["INFLUXDB_URL"],
  ENV["INFLUXDB_TOKEN"]
)
bucket = ENV["INFLUXDB_BUCKET"]
org = ENV["INFLUXDB_ORG"]

def value(tables, field)
  tables.find {|i, t| t.records[0].field == field}[1].records[0].value
end

SCHEDULER.every '5s' do
  query = "from(bucket: \"#{bucket}\") |> range(start: -2h) |> filter(fn: (r) => r._measurement == \"solar\") |> last()"
  tables = client.create_query_api.query(query: query, org: org)

  send_event('stateofcharge', { value: value(tables, "soc") })
  send_event('load', { current: value(tables, "load").round(1) })
  send_event('charge', { current: value(tables, "charge").round(1) })
end
