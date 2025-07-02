#!/usr/bin/env ruby
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
    { 'jsonrpc' => '2.0', 'id' => request['id'], 'error' => { 'code' => -32_601, 'message' => 'Method not found' } }
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
  rescue StandardError => e
    error_response = {
      'jsonrpc' => '2.0',
      'id' => request && request['id'],
      'error' => { 'code' => -32_603, 'message' => e.message }
    }
    logger.error("OUTPUT ERROR: #{error_response.to_json}")
    STDOUT.puts(error_response.to_json)
    STDOUT.flush
  end
end

# dir:server
#   dir:src
#     dir:service
#       dir:calendar
#         file:create_service.rb
#         file:list_service.rb
#         file:update_service.rb
#         file:delete_service.rb
#       dir:event
#         file:create_service.rb
#         file:list_service.rb
#         file:update_service.rb
#         file:delete_service.rb
#     dir:presenter
#       file:calendar_presenter.rb
#       file:event_presenter.rb
#     dir:repository
#       file:calendar_repository.rb
#       file:event_repository.rb
#     dir:procedure
#       dir:calendar
#         file:create_procedure.rb
#         file:list_procedure.rb
#         file:update_procedure.rb
#         file:delete_procedure.rb
#       dir:event
#         file:create_procedure.rb
#         file:list_procedure.rb
#         file:update_procedure.rb
#         file:delete_procedure.rb
#   dir:lib
#     file:icalendar.rb
#
#   dir:config
#     file:calendar.yml
#   dir:log
#     file:rpc.log
#   file:server.rb
