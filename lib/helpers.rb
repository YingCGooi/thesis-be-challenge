def overlap_appt?(a, b)
  a.start_time <= b.end_time && 
  a.end_time >= b.start_time
end

def valid_insertion?(schedule, mid, appt)
  return schedule[mid].end_time > appt.start_time if mid == 0

  schedule[mid].end_time > appt.start_time &&
  schedule[mid - 1].end_time < appt.start_time
end

def past_final_appt?(last_appt, appt)
  return true if last_appt.nil?
  last_appt.end_time < appt.start_time
end

def binary_search(schedule, appt)
  left = 0
  right = schedule.length - 1

  loop do
    mid = (left + right) / 2
    curr_appt = schedule[mid]
    return false if overlap_appt?(curr_appt, appt)
    return mid if valid_insertion?(schedule, mid, appt)

    if curr_appt.end_time > appt.end_time
      next right = mid - 1
    end

    if curr_appt.end_time < appt.end_time
      next left = mid + 1
    end
  end
end