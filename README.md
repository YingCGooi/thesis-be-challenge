# Thesis Backend Challenge: Schedule API

## Set-up
1. Make sure that you have Ruby version 2.4.1 installed and running locally.

2. In the root directory of this project, run `bundle install` to install dependencies.

3. Then, run `bundle exec ruby server.rb` to run the server.

4. You can now access the API endpoints (read documentation below).

## API Documentation
### GET `/api/schedules`
- returns a json containing all schedules and their associated appointments
- curl example: 
```
curl http://localhost:4567/api/schedules
```

### GET `/api/schedules/:id`
- params: id
- returns a json array containing all appointments in the specified schedule
- curl example:
```
curl http://localhost:4567/api/schedules/0
```
- 404 with an error message if the schedule is not found

### POST `/api/schedules`
- creates a new schedule with no appointments
- returns a json object representing the created schedule object
- curl example:
```
curl -X POST http://localhost:4567/api/schedules
```

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
- curl example:
```

```

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

## 
