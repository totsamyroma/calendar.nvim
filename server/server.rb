#!/usr/bin/env ruby
$stdout.sync = true
STDOUT.sync = true

require 'json'
require 'logger'

log_dir = File.expand_path('../server/log', __dir__)
Dir.mkdir(log_dir) unless Dir.exist?(log_dir)
logger = Logger.new(File.join(log_dir, 'rpc.log'))

def handle_request(request)
  case request['method']
  when 'add_calendar'
    # Example: params = { "name" => "work", "url" => "https://example.com/calendar.ics" }
    # TODO: Implement actual storage logic
    { 'jsonrpc' => '2.0', 'id' => request['id'], 'result' => "Added calendar #{request['params']['name']}" }
  when 'list_calendars'
    # TODO: Implement actual retrieval logic
    calendars = [{ 'name' => 'work', 'url' => 'https://example.com/calendar.ics' }]
    { 'jsonrpc' => '2.0', 'id' => request['id'], 'result' => calendars }
  else
    { 'jsonrpc' => '2.0', 'id' => request['id'], 'error' => { 'code' => -32601, 'message' => 'Method not found' } }
  end
end

while line = STDIN.gets
  begin
    logger.info("INPUT: #{line.strip}")
    request = JSON.parse(line)
    response = handle_request(request)
    logger.info("OUTPUT: #{response.to_json}")
    STDOUT.puts(response.to_json)
    STDOUT.flush
  rescue => e
    error_response = {
      'jsonrpc' => '2.0',
      'id' => request && request['id'],
      'error' => { 'code' => -32603, 'message' => e.message }
    }
    logger.error("OUTPUT ERROR: #{error_response.to_json}")
    STDOUT.puts(error_response.to_json)
    STDOUT.flush
  end
end
