# Thesis Backend Challenge: Schedule API

## Set-up
1. Make sure that you have Ruby version 2.4.1 installed and running locally.

2. In the root directory of this project, run `bundle install` to install dependencies.

3. Then, run `bundle exec ruby server.rb` to run the server.

4. You can now access the API endpoints (read documentation below).

## API Documentation
### GET `/api/schedules`
- returns a json containing all schedules and their associated appointments

### GET `/api/schedules/:id`
- params: id
- returns a json array containing all appointments in the specified schedule
- 404 with an error message if the schedule is not found

### POST `/api/schedules`
- creates a new schedule with no appointments
- returns a json object representing the created schedule object

### POST `/schedules/:id/appointments`
- creates a new appointment on the specified schedule
- params: id, start_time, end_time
- returns the new appointment object
- curl example:
```
curl -X POST -F 'start_time=1' -F 'end_time=2' http://localhost:4567/api/schedules/0/appointments
```
- 404 if the specified schedule id is not found
- 400 if the start_time or end_time are invalid, or an overlap is possible

### DELETE `schedules/:id`
- deletes a schedule with its associated appointments
- params: id
- 404 if schedule is not found

### DELETE `/appointments/:id`
- deletes an appointment
- params: id
- 404 if appointment is not found

### DELETE `/schedules/:schedule_id/appointments/:appt_id`
- deletes an appointment in the specified schedule
- params: schedule_id, appt_id
- returns 404 if appointment is not in specified schedule or not found

### GET `/appointments/:id`
- returns a single appointment json
- params: id
- returns 404 if appointment is not found

### GET `/schedules/:schedule_id/appointments/:appt_id`
- returns a single appointment json in the specified schedule
- params: schedule_id, appt_id
- returns 404 if appointment is not in specified schedule or not found

## Data Design
For this project, I use in-memory storage in the form of hash tables. If the requirement states to persist data, we could choose to write the data to a YAML or JSON file, or even use a RDBMs to enable SQL operations. For now, in-memory storage is fine since we're going to focus on the API features.

Schedules object:
```
{
  0: [...appointments],
  1: [...appointments]
}
```

The schedules object is a hash table with the ID number as key and associated appointments as value.

Appointment object:
```
{ id: 1, start_time: 1, end_time: 2 }
```

Each appointment object will contain an id attribute to allow easy retrieval and deletion.

## New Appointment Validation
All appointments are ordered based on their start and end times.
When a new appointment is being created, a binary search is performed to determine the position in which it will be inserted.
A validation is also run to ensure that there are no overlaps.

## Tests
To run tests on the model layer:
```
bundle exec ruby test/model_test.rb
```

To run tests on the API:
```
bundle exec ruby test/api_test.rb
```
