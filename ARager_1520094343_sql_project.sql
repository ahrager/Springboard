/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name FROM Facilities
WHERE membercost > 0

/*
Tennis Court 1
Tennis Court 2
Message Room 1
Message Room 2
Squash Court
*/


/* Q2: How many facilities do not charge a fee to members? */

SELECT count(facid) FROM Facilities
WHERE membercost = 0

/*
Four (4) facilities do not charge a fee to members.
*/


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance 
FROM Facilities
WHERE membercost > 0
AND membercost < (monthlymaintenance * 0.2)

/*
facid          name                 membercost     monthlymaintenance
0           Tennis Court 1            5.0               200
1           Tennis Court 2            5.0               200
4           Massage Room 1            9.9              3000
5           Massage Room 2            9.9              3000
6            Squash Court             3.5                80
*/


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT * FROM Facilities
WHERE facid in (1, 5)

/*
facid          name                 membercost     monthlymaintenance
1           Tennis Court 2            5.0               200
5           Massage Room 2            9.9              3000
*/

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */


SELECT name,
       monthlymaintenance,
       CASE WHEN monthlymaintenance > 100 THEN 'expensive'
       ELSE 'cheap' end as maintenance_category
FROM Facilities

/*
name.               monthlymaintenance.         maintenance_category
Tennis Court 1            200                       expensive
Tennis Court 2            200                       expensive
Badminton Court            50                         cheap
Table Tennis               10                         cheap
Massage Room 1           3000                       expensive
Massage Room 2           3000                       expensive
Squash Court               80                         cheap
Snooker Table              15                         cheap
Pool Table                 15                         cheap
*/

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members
WHERE joindate = (
    SELECT MAX(joindate)
    FROM Members
)

/*
firstname     surname
Darren        Smith
*/


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT F.name as facility_name,
                concat(M.firstname , ' ', M.surname) as member_name 
FROM Bookings B 
INNER JOIN Facilities F ON B.facid = F.facid
INNER JOIN Members M ON B.memid = M.memid
                     AND B.memid > 0
WHERE F.name LIKE 'Tennis Court%'
ORDER BY 2

/*
facility_name              member_name
Tennis Court 2             Anne Baker
Tennis Court 1             Anne Baker 
Tennis Court 1             Burton Tracy
Tennis Court 2             Burton Tracy
Tennis Court 2             Charles Owen
Tennis Court 1             Charles Owen
Tennis Court 2             Darren Smith
Tennis Court 2             David Farrell
Tennis Court 1             David Farrell
Tennis Court 1             David Jones
Tennis Court 2             David Jones
Tennis Court 1             David Pinker
Tennis Court 1             Douglas Jones
Tennis Court 1             Erica Crumpet
Tennis Court 2             Florence Bader
Tennis Court 1             Florence Bader
Tennis Court 1             Gerald Butters
Tennis Court 2             Gerald Butters
Tennis Court 2             Henrietta Rumney
Tennis Court 1             Jack Smith
Tennis Court 2             Jack Smith
Tennis Court 1             Janice Joplette
Tennis Court 2             Janice Joplette
Tennis Court 1             Jemima Farrell
Tennis Court 2             Jemima Farrell
Tennis Court 1             Joan Coplin
Tennis Court 1             John Hunt
Tennis Court 2             John Hunt
Tennis Court 1             Matthew Genting
Tennis Court 2             Millicent Purview
*/


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */


SELECT F.name as facility_name,
       concat(M.firstname , ' ', M.surname) as user_name,
       CASE WHEN B.memid = 0 THEN (B.slots * F.guestcost)
            ELSE (B.slots * F.membercost)
       END as cost
FROM Bookings B 
INNER JOIN Facilities F ON B.facid = F.facid
                        AND B.starttime like '2012-09-14%'
INNER JOIN Members M ON B.memid = M.memid
WHERE (CASE WHEN B.memid = 0 THEN (B.slots * F.guestcost)
            ELSE (B.slots * F.membercost)
       END) > 30
ORDER BY 3 DESC

/*
facility_name             user_name             cost
Massage Room 2           GUEST GUEST            320.0
Massage Room 1           GUEST GUEST            160.0
Massage Room 1           GUEST GUEST            160.0
Massage Room 1           GUEST GUEST            160.0
Tennis Court 2           GUEST GUEST            150.0
Tennis Court 1           GUEST GUEST             75.0
Tennis Court 1           GUEST GUEST             75.0
Tennis Court 2           GUEST GUEST             75.0
Squash Court             GUEST GUEST             70.0
Massage Room 1          Jemima Farrell           39.6
Squash Court             GUEST GUEST             35.0
Squash Court             GUEST GUEST             35.0
*/


/* Q9: This time, produce the same result as in Q8, but using a subquery. */


SELECT sub.facility_name,
       concat(M.firstname , ' ', M.surname) as user_name,
       sub.cost
FROM Members M
INNER JOIN (
    SELECT F.name as facility_name,
           B.memid as memid,
           CASE WHEN B.memid = 0 THEN (B.slots * F.guestcost)
                ELSE (B.slots * F.membercost)
           END AS COST
    FROM Bookings B
    INNER JOIN Facilities F
    ON B.facid = F.facid
    AND B.starttime like '2012-09-14%'
    ) sub on M.memid = sub.memid
where sub.cost > 30
ORDER BY 3 DESC


/*
facility_name          user_name           cost
Massage Room 2        GUEST GUEST         320.0
Massage Room 1        GUEST GUEST         160.0
Massage Room 1        GUEST GUEST         160.0
Massage Room 1        GUEST GUEST         160.0
Tennis Court 2        GUEST GUEST         150.0
Tennis Court 2        GUEST GUEST          75.0
Tennis Court 1        GUEST GUEST          75.0
Tennis Court 1        GUEST GUEST          75.0
Squash Court          GUEST GUEST          70.0
Massage Room 1      Jemima Farrell         39.6
Squash Court          GUEST GUEST          35.0
Squash Court          GUEST GUEST          35.0
*/

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT F.name AS facility_name,
       sub1.total_revenue
FROM Facilities F
INNER JOIN (
    SELECT F.facid as facid,
           sum(
               CASE WHEN sub2.client_type = 'guest' THEN sub2.total_slots * F.guestcost
                    ELSE sub2.total_slots * F.membercost
               END
           ) AS total_revenue
    FROM Facilities F
    INNER JOIN (
        SELECT F.facid AS facid,
               CASE WHEN B.memid = 0 THEN 'guest' ELSE 'member' END AS client_type,
               sum(B.slots) AS total_slots
        FROM Bookings B
        INNER JOIN Facilities F ON B.facid = F.facid
        GROUP BY facid, client_type
    ) sub2 ON F.facid = sub2.facid
    GROUP BY 1
) sub1 ON F.facid = sub1.facid
WHERE sub1.total_revenue < 1000
ORDER BY 2

/*
facility_name         total_revenue
Table Tennis             180.0
Snooker Table            240.0
Pool Table               270.0
*/
