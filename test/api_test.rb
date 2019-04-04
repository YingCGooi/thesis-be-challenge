ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/reporters'
require 'rack/test'
require 'json'
require_relative '../server'
require_relative '../lib/model'

Minitest::Reporters.use!

class APITest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def save_appointment!(id, start_time, end_time)
    Schedule.save(id: id, appt: Appointment.new(start_time, end_time))
  end   

  def setup
    Schedule.new
    save_appointment!(0, 1, 2)
    save_appointment!(0, 6, 7)
    save_appointment!(0, 100, 200)
    save_appointment!(0, 201, 202)
    save_appointment!(0, 240, 260)
    Schedule.new
    save_appointment!(1, 1, 2)
    save_appointment!(1, 3, 4)
  end

  def teardown
    Schedule.destroy_all!
    Schedule.reset_id
    Appointment.reset_id    
  end

  def test_get_all_schedules
    get '/api/schedules'
    assert_equal 200, last_response.status

    json = JSON.parse(last_response.body)
    assert_equal 2, json.length
    assert_equal 5, json['0'].length
    assert_equal 2, json['1'].length
  end

  def test_get_appointments_in_a_schedule
    get '/api/schedules/0'
    assert_equal 200, last_response.status

    json = JSON.parse(last_response.body)
    assert_equal 5, json.length
  end

  def test_create_a_schedule
    post '/api/schedules'
    assert_equal 201, last_response.status

    schedules = Schedule.all
    assert_equal 3, schedules.length
  end

  def test_create_valid_new_appointment
    post '/api/schedules/1/appointments', { start_time: 5, end_time: 6 }
    assert_equal 201, last_response.status

    schedule = Schedule[1]
    assert_equal 3, schedule.length
    assert_equal 6, schedule.last.end_time
  end

  def test_create_invalid_new_appointment
    post '/api/schedules/1/appointments', { start_time: 5, end_time: 4 }
    assert_equal 400, last_response.status

    schedule = Schedule[1]
    assert_equal 2, schedule.length
  end

  def test_create_overlap_appointment
    post '/api/schedules/1/appointments', { start_time: 4, end_time: 6 }
    assert_equal 400, last_response.status

    schedule = Schedule[1]
    assert_equal 2, schedule.length
  end

  def test_delete_appointment
    delete '/api/schedules/1/appointments/5'
    assert_equal 204, last_response.status

    schedule = Schedule[1]
    assert_equal 1, schedule.length
    assert_equal({ id: 6, start_time: 3, end_time: 4 }, schedule.last.to_hash)
  end

  def test_get_single_appointment
    get '/api/schedules/1/appointments/5'
    assert_equal 200, last_response.status

    json = JSON.parse(last_response.body)
    assert_equal({"id" => 5, "start_time" => 1, "end_time" => 2}, json)
  end
end