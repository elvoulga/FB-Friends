/*
  BigData Management - Assignment_2 

  Karydis Athanasios - A.M. 17008 - email: dsc17008@uop.gr
  Voulgari Eleni - A.M. 17005 - email: dsc17005@uop.gr

  Implementation of Counting Friends of a user in Facebook social network.
*/


--Use Load statement to load the data from the file selected by the user. As we don't have columns, we define only one column named relationships
line = LOAD '$input' USING PigStorage('\n')  AS (relationships:chararray);


--Split each line into the user, which is the first username of the line, and his friends, which are the rest
splits = FOREACH line GENERATE FLATTEN(STRSPLIT(relationships,' ',2)) AS (user:chararray, friends:chararray);


--Create the correct tuples with the form (user, tuple[friend, friend2, ...])
correct = FOREACH splits GENERATE user, STRSPLIT(friends, ' ') AS (friends_list:TUPLE()); 


--For each of the above tuples create the outpout (user, count_of_friends)
count = FOREACH correct GENERATE user, SIZE(friends_list); 


--Order the output in asceding order
ordered_count = ORDER count BY user;


--Write the result to a file in the selected by the user folder
STORE ordered_count INTO '$output' USING PigStorage(',');
