require 'json'
require_relative 'helpers'

class InvalidAppointmentError < StandardError; end
class NotFoundError < StandardError; end

class Schedule
  @@curr_id = 0
  @@schedules = {}

  NOT_FOUND_MESSAGE = 'No schedule found for the requested ID!'

  attr_reader :id

  def initialize
    @id = @@curr_id
    @@schedules[@@curr_id] = []
    @@curr_id += 1
  end

  def self.all
    @@schedules
  end

  def self.[](id)
    raise NotFoundError, NOT_FOUND_MESSAGE if @@schedules[id].nil?
    @@schedules[id]
  end

  def self.save(id:, appt:)
    raise NotFoundError, NOT_FOUND_MESSAGE if @@schedules[id].nil?

    schedule = @@schedules[id]

    index_to_insert =
      if past_final_appt?(schedule.last, appt)
        schedule.length
      else 
        binary_search(schedule, appt)
      end

    raise InvalidAppointmentError, 'Overlapping with an existing appointment!' unless index_to_insert

    schedule.insert(index_to_insert, appt)
    appt.schedule_id = id
    appt
  end

  def self.destroy!(id)
    raise NotFoundError, NOT_FOUND_MESSAGE if @@schedules[id].nil?
    @@schedules.delete(id)
  end

  def self.destroy_all!
    Appointment.destroy_all!
    @@schedules = {}
  end

  def self.reset_id
    @@curr_id = 0
  end

  def to_s
    "<Schedule ##{@id} - Appts: #{@@schedules[@id]}>"
  end
end

class Appointment
  @@curr_id = 0
  @@appointments = {}

  attr_reader :id, :start_time, :end_time
  attr_accessor :schedule_id

  NOT_FOUND_MESSAGE = 'No appointment found for the requested ID!'

  def initialize(start_time, end_time)
    raise InvalidAppointmentError, 'Times must be non-negative' if start_time < 0 || end_time < 0
    raise InvalidAppointmentError, 'End time must be greater than the start time!' if start_time >= end_time
    @id = @@curr_id
    @start_time = start_time
    @end_time = end_time

    @@appointments[@@curr_id] = self
    @@curr_id += 1
  end

  def self.all
    @@appointments
  end

  def self.[](id)
    raise NotFoundError, NOT_FOUND_MESSAGE if @@appointments[id].nil?
    @@appointments[id]
  end

  def self.destroy!(id)
    raise NotFoundError, NOT_FOUND_MESSAGE if @@appointments[id].nil?
    schedule_id = Appointment[id].schedule_id
    Schedule[schedule_id].delete_if { |appt| appt.id == id }
    @@appointments.delete(id)
  end

  def self.destroy_all!
    @@appointments = {}
  end

  def self.reset_id
    @@curr_id = 0
  end

  def to_hash
    { id: @id, start_time: @start_time, end_time: @end_time }
  end

  def to_s
    "<Appt ##{@id} | start: #{@start_time} | end: #{@end_time} >"
  end
end