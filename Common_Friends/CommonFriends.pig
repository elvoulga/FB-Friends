/*
  BigData Management - Assignment_2 

  Karydis Athanasios - A.M. 17008 - email: dsc17008@uop.gr
  Voulgari Eleni - A.M. 17005 - email: dsc17005@uop.gr

  Implementation of Common Friends between pairs of users in Facebook social network.
*/


REGISTER 'datafu-0.0.5.jar' ;
DEFINE SetIntersect datafu.pig.bags.sets.SetIntersect();

--Use Load statement to load the data from the file selected by the user. As we don't have columns, we define only one column named relationships
line = LOAD '$input' USING PigStorage('\n')  AS (relationships:chararray);

--Split each line into the user, which is the first username of the line, and his friends, which are the rest
splits = FOREACH line GENERATE FLATTEN(STRSPLIT(relationships,' ',2)) AS (user:chararray, friends:chararray); 

--Create the pairs (friend1, friend2) for all possible combinations, filtering them to remove the pairs that contain the same persons, keeping the ones that are ordered alphabetically
pairs = FILTER(FOREACH splits GENERATE user, FLATTEN(TOKENIZE(friends)) AS tokens) BY (user < tokens); 

--Create a tuple which contains the user and his friends in a tuple of the form (user, (friend1, friend2, ...)) 
user_friends = FOREACH splits GENERATE user, TOKENIZE(friends) AS friends;

--Join the pairs of friends with the tuple of the first person's user. This is done by joining on user. eg. A L	A {(B),(C),(D),(G),(E),(F),(L)}
first_friends = JOIN pairs BY user, user_friends BY user;

--Joins the above result with the friends of the second person of the pair. eg. A B A {(B),(C),(D),(G),(E),(F),(L)} B {(I),(A),(J),(C),(K),(D),(E),(F),(H)}
second_friends = JOIN first_friends BY pairs::tokens, user_friends BY user;

--Keep only the columns of interest, thus the pair of users and the tuples of their friends to apply the intersection. eg. A B {(B),(C),(D),(G),(E),(F),(L)} {(I),(A),(J),(C),(K),(D),(E),(F),(H)}
before_intersection = FOREACH second_friends GENERATE $0 AS friend1, $1 AS friend2, $3 AS user1_friends, $5 AS user2_friends;

--Use of the package datafu (.jar file) where intersection method "SetIntesect" exists. This method needs the data to be ordered in order to perform the intersection. eg. A B {(C),(D),(E),(F)}
after_intersection = FOREACH before_intersection 
{
    ord1 = ORDER user1_friends BY token;   
    ord2 = ORDER user2_friends BY token;
    GENERATE friend1 AS f1, friend2 AS f2,  BagToTuple(SetIntersect(ord1,ord2)) AS common;
};

--Asceding order of the results by friend1 and by friend2 of the pair respectively
ordered_result = ORDER after_intersection BY f1,f2 ASC;

--Produce the final result by creating a tuple with the pair of users and a tuple with their common friends
final_result = FOREACH ordered_result GENERATE TOTUPLE(f1, f2), common;

--Store the final result in the folder chosen by the user
STORE final_result INTO '$output';




