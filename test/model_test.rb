require 'minitest/autorun'
require 'minitest/reporters'
require_relative '../lib/model'

Minitest::Reporters.use!

class ModelTest < Minitest::Test
  def setup
    Schedule.new()
    save_appointment!(1, 2)
    save_appointment!(6, 7)
    save_appointment!(100, 200)
    save_appointment!(201, 202)
    save_appointment!(240, 260)
  end

  def teardown
    Schedule.destroy_all!
    Schedule.reset_id
    Appointment.reset_id
  end

  def save_appointment!(start_time, end_time)
    Schedule.save(id: 0, appt: Appointment.new(start_time, end_time))
  end 

  def test_save_overlap_appointment
    error = InvalidAppointmentError
    assert_raises(error) { save_appointment!(1, 2) }
    assert_raises(error) { save_appointment!(1, 3) }
    assert_raises(error) { save_appointment!(2, 3) }
    assert_raises(error) { save_appointment!(3, 6) }
    assert_raises(error) { save_appointment!(150, 215) }
    assert_raises(error) { save_appointment!(203, 240) }
  end

  def test_save_valid_appointment
    appt = save_appointment!(3, 4)
    assert_equal appt, Schedule[0][1]
  end

  def test_save_valid_appointment_2
    appt = save_appointment!(203, 239)
    assert_equal appt, Schedule[0][4]
  end

  def test_save_valid_appointment_3
    appt = save_appointment!(280, 290)
    assert_equal appt, Schedule[0].last
  end

  def test_save_invalid_appointment
    error = InvalidAppointmentError
    assert_raises(error) { save_appointment!(4, 3) }
    assert_raises(error) { save_appointment!(-1, 2) }
  end

  def test_retrieve_a_schedule
    assert_equal 5, Schedule[0].length
  end

  def test_retrieve_non_existing_schedule
    assert_raises(NotFoundError) { Schedule[999] }
  end

  def test_destroy_a_schedule
    Schedule.new()
    assert_equal 2, Schedule.all.length

    Schedule.destroy!(0)
    assert_equal 1, Schedule.all.length
  end

  def test_destroy_an_appointment
    Appointment.destroy!(0)
    assert_equal 4, Schedule[0].length
  end

  def test_destroy_a_non_existing_appointment
    assert_raises(NotFoundError) { Appointment.destroy!(999) }
  end

  def test_retrieve_an_appoinment
    appt = save_appointment!(203, 239)
    assert_includes Appointment.all.values, appt
  end

  def test_retrieve_non_existing_appointment
    assert_raises(NotFoundError) { Appointment[999] }
  end
end