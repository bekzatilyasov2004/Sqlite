# Welcome to My Sqlite
This task is all about using SQL
In this poject we made use of SQL(Structured query language) to Query data.
This project enables you to selct data from a file , insert data and update the file , all with specific Queries.
In this prooject we will also be working with CVS.
We need to ensure that when writing to the CSV, we maintain the correct format. 
When reading the CSV, we need to handle headers correctly and parse data accurately.

## Task
Create a program which will be a Command Line Interface (CLI) to your MySqlite class.
It will accept request with:
SELECT|INSERT|UPDATE|DELETE
FROM      
WHERE (max 1 condition)
Here is an an example of the type of data we will be dealing with in this project:
name,year_start,year_end,position,height,weight,birth_date,college
All this data will be for NBA players.
At the end we will then need to run our own test on each file in this project to make sure that there are no errors.

## Description
I created a class called MySqliteRequest in my_sqlite_request.rb. 
It will have a similar behavior than a request on the real sqlite.
All methods, except run, will return an instance of my_sqlite_request. 
You will build the request by progressive call and execute the request by calling run.
Well will then run test to ensure the tests reflect the correct usage and data parsing logic.
To run the tests, execute the test file using Ruby: { ruby my_sqlite_request_test.rb } in your terminal.

## Installation
There are no packages needed to run this project.
But to get this project you can view it on my github repo.
you can also fork the source code from my repo.
And lastly you can download as a zip file to your machine locally.

## Usage
```
./my_project argument1 argument2
```

### The Core Team


<span><i>Made at <a href='https://qwasar.io'>Qwasar SV -- Software Engineering School</a></i></span>
<span><img alt='Qwasar SV -- Software Engineering School's Logo' src='https://storage.googleapis.com/qwasar-public/qwasar-logo_50x50.png' width='20px' /></span>
