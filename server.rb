require 'sinatra'
require 'sinatra/multi_route'
require 'sinatra/contrib'
require 'rack/contrib'
require_relative 'lib/model'

use Rack::PostBodyContentTypeParser

configure(:development) do
  require 'sinatra/reloader'
  also_reload './lib/model.rb'
end

def save_appointment!(start_time, end_time)
  Schedule.save(id: 0, appt: Appointment.new(start_time, end_time))
end

get '/' do
  'Schedule API: Use the /api endpoints to begin.'
end

namespace '/api' do
  helpers do
    def to_schedules_object(schedules)
      schedules.map do |id, schedule| 
        [id, to_schedule_object(schedule)] 
      end.to_h
    end

    def to_schedule_object(schedule)
      schedule.map(&:to_hash)
    end
  end

  # show all schedules and appointments
  get '/schedules' do
    json to_schedules_object(Schedule.all)
  end

  # show all appointments in a particular schedule
  get '/schedules/:id' do
    id = params[:id].to_i

    begin
      schedule = Schedule[id]
      json to_schedule_object(schedule)

    rescue NotFoundError => e
      halt 404, e.message
    end
  end

  post '/schedules' do
    status 201
    id = Schedule.new.id
    json({ id => [] })
  end

  # create a new appointment on the specified schedule
  post '/schedules/:id/appointments' do
    id = params[:id].to_i
    start_time = params[:start_time].to_i
    end_time = params[:end_time].to_i

    begin
      schedule = Schedule[id]
      appt = Appointment.new(start_time, end_time)
      new_appt = Schedule.save(id: id, appt: appt)

      status 201
      json new_appt.to_hash

    rescue NotFoundError => e
      halt 404, e.message

    rescue InvalidAppointmentError => e
      halt 400, e.message

    end
  end

  # delete a schedule
  delete '/schedules/:id' do
    id = params[:id].to_i

    begin
      Schedule.destroy!(id)
      halt 204
    rescue NotFoundError => e
      halt 404, e.message
    end
  end

  # delete an appointment
  delete '/appointments/:id' do
    id = params[:id].to_i

    begin
      Appointment.destroy!(id)
      halt 204
    rescue NotFoundError => e
      halt 404, e.message
    end
  end

  # delete an appointment in the specified schedule
  delete '/schedules/:schedule_id/appointments/:appt_id' do
    schedule_id = params[:schedule_id].to_i
    appt_id = params[:appt_id].to_i

    begin
      appt = Appointment[appt_id]
      if appt.schedule_id != schedule_id
        halt 404, 'Schedule not found for this appointment.'
      end

      Appointment.destroy!(appt_id)
      halt 204

    rescue NotFoundError => e
      halt 404, e.message
    end
  end

  # show a single appointment
  get '/appointments/:id' do
    id = params[:id].to_i

    begin
      json Appointment[id].to_hash

    rescue NotFoundError => e
      halt 404, e.message
    end
  end

  # show a single appointment in the specified schedule
  get '/schedules/:schedule_id/appointments/:appt_id' do
    schedule_id = params[:schedule_id].to_i
    appt_id = params[:appt_id].to_i

    begin
      appt = Appointment[appt_id]
      if appt.schedule_id != schedule_id
        halt 404, 'Schedule not found for this appointment.'
      end
      json appt.to_hash

    rescue NotFoundError => e
      halt 404, e.message
    end
  end
end