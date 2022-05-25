require 'influxdb-client'

client = InfluxDB2::Client.new(
  ENV["INFLUXDB_URL"],
  ENV["INFLUXDB_TOKEN"]
)
bucket = ENV["INFLUXDB_BUCKET"]
org = ENV["INFLUXDB_ORG"]

def value(tables, field)
  tables.find {|i, t| t.records[0].field == field}[1].records[0].value
end

def a_to_w(amps)
  amps * 24
end

def ah_to_wh(value)
  value * 24
end

SCHEDULER.every '5s' do
  query = "from(bucket: \"#{bucket}\") |> range(start: -2h) |> filter(fn: (r) => r._measurement == \"solar\") |> last()"
  tables = client.create_query_api.query(query: query, org: org)

  send_event('stateofcharge', { value: value(tables, "soc") })
  send_event('load', { current: a_to_w(value(tables, "load")).round(0) })
  send_event('charge', { current: a_to_w(value(tables, "charge")).round(0) })
  send_event('chargeminusload', { current: a_to_w(value(tables, "charge") - value(tables, "load")).round(0) })
  send_event('in', { current: ah_to_wh(value(tables, "in")).round(0) })
  send_event('out', { current: ah_to_wh(value(tables, "out")).round(0) })
end
