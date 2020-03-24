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

SELECT name 
FROM Facilities 
WHERE membercost > 0

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(*) AS no_fee_count
FROM Facilities 
WHERE membercost = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, 
	   name, 
	   membercost, 
	   monthlymaintenance
FROM Facilities
WHERE membercost > 0
AND membercost < (.2 * monthlymaintenance)

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid IN (1, 5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, 
	   monthlymaintenance,
	   CASE WHEN monthlymaintenance <= 100 THEN 'cheap'
			ELSE 'expensive' END AS cheap_or_expensive
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT m.firstname AS first_name,
       m.surname AS last_name
FROM Members m
JOIN (SELECT MAX(mm.joindate) AS max_date
	FROM Members mm) t
ON t.max_date = m.joindate

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

/* replace the following to go from SQL to SQLite3: 
ELSE CONCAT(m.firstname, ' ', m.surname)
ELSE m.firstname || ' ' || m.surname
*/
SELECT DISTINCT CONCAT(m.firstname, ' ', m.surname) AS member_name, -- here
       CASE WHEN m.firstname IN (
                              SELECT tm.firstname
                                  FROM country_club.Bookings tb
                                  JOIN country_club.Members tm
                                    ON tb.memid = tm.memid 
                                  JOIN country_club.Facilities tf
                                    ON tb.facid = tf.facid
                                  WHERE tf.name = 'Tennis Court 1'
                                ) 
             AND m.surname IN (
                              SELECT tm.surname
                                  FROM country_club.Bookings tb
                                  JOIN country_club.Members tm
                                    ON tb.memid = tm.memid 
                                  JOIN country_club.Facilities tf
                                    ON tb.facid = tf.facid
                                  WHERE tf.name = 'Tennis Court 1'
                                )
             AND m.firstname IN (
                              SELECT tm.firstname
                                  FROM country_club.Bookings tb
                                  JOIN country_club.Members tm
                                    ON tb.memid = tm.memid 
                                  JOIN country_club.Facilities tf
                                    ON tb.facid = tf.facid
                                  WHERE tf.name = 'Tennis Court 2'
                                ) 
             AND m.surname IN (
                              SELECT tm.surname
                                  FROM country_club.Bookings tb
                                  JOIN country_club.Members tm
                                    ON tb.memid = tm.memid 
                                  JOIN country_club.Facilities tf
                                    ON tb.facid = tf.facid
                                  WHERE tf.name = 'Tennis Court 2'
                                ) 
            THEN 'Tennis Court 1, 2'
            WHEN m.firstname IN (
                              SELECT tm.firstname
                                  FROM country_club.Bookings tb
                                  JOIN country_club.Members tm
                                    ON tb.memid = tm.memid 
                                  JOIN country_club.Facilities tf
                                    ON tb.facid = tf.facid
                                  WHERE tf.name = 'Tennis Court 1'
                                ) 
            AND m.surname IN (
                              SELECT tm.surname
                                  FROM country_club.Bookings tb
                                  JOIN country_club.Members tm
                                    ON tb.memid = tm.memid 
                                  JOIN country_club.Facilities tf
                                    ON tb.facid = tf.facid
                                  WHERE tf.name = 'Tennis Court 1'
                                ) 
            THEN 'Tennis Court 1'
            WHEN m.firstname IN (
                              SELECT tm.firstname
                                  FROM country_club.Bookings tb
                                  JOIN country_club.Members tm
                                    ON tb.memid = tm.memid 
                                  JOIN country_club.Facilities tf
                                    ON tb.facid = tf.facid
                                  WHERE tf.name = 'Tennis Court 2'
                                ) 
            AND m.surname IN (
                              SELECT  tm.surname
                                  FROM country_club.Bookings tb
                                  JOIN country_club.Members tm
                                    ON tb.memid = tm.memid 
                                  JOIN country_club.Facilities tf
                                    ON tb.facid = tf.facid
                                  WHERE tf.name = 'Tennis Court 2'
                                ) 
            THEN 'Tennis Court 2'
        END AS booked_court
FROM country_club.Members m
JOIN country_club.Bookings b
ON m.memid = b.memid
JOIN country_club.Facilities f
ON f.facid = b.facid
WHERE f.name LIKE 'Tennis Court%'
AND ((m.firstname != 'GUEST') OR (m.surname != 'GUEST'))
ORDER BY member_name

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

/* replace the following to go from SQL to SQLite3: 
ELSE CONCAT(m.firstname, ' ', m.surname)
ELSE m.firstname || ' ' || m.surname
*/
SELECT f.name AS facility_name,
           CASE WHEN m.firstname = 'GUEST' THEN m.firstname 
                ELSE CONCAT(m.firstname, ' ', m.surname) END AS member_name, -- here
           CASE WHEN ((b.memid > 0) AND ((b.slots * f.membercost) > 30)) THEN (b.slots * f.membercost)
                WHEN ((b.memid = 0) AND ((b.slots * f.guestcost) > 30)) THEN (b.slots * f.guestcost)
                ELSE 0 END AS booking_cost
        FROM country_club.Bookings b
        JOIN country_club.Members m
        ON m.memid = b.memid
        JOIN country_club.Facilities f
        ON f.facid = b.facid
    WHERE b.starttime >= '2012-09-14'
    AND b.starttime < '2012-09-15'
    AND (
        ((b.memid > 0) AND ((b.slots * f.membercost) > 30))
        OR 
        ((b.memid = 0) AND ((b.slots * f.guestcost) > 30))
        )
    ORDER BY booking_cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

/* replace the following to go from SQL to SQLite3: 
ELSE CONCAT(dsub.firstname, ' ', dsub.surname) 
ELSE dsub.firstname || ' ' || dsub.surname
*/
SELECT dsub.name AS facility_name,
	   CASE WHEN dsub.firstname = 'GUEST' THEN dsub.firstname 
			ELSE CONCAT(dsub.firstname, ' ', dsub.surname) END AS member_name, -- here
       dsub.cost AS booking_cost
FROM
  (
   SELECT b.bookid, b.facid, b.memid,
          m.surname, m.firstname,
          f.name, f.membercost, f.guestcost,
          CASE WHEN b.memid = 0 THEN b.slots * f.guestcost
            ELSE b.slots * f.membercost END AS cost
    FROM Bookings b
    JOIN Members m
    ON m.memid = b.memid
    JOIN Facilities f
    ON f.facid = b.facid
    WHERE b.starttime >= '2012-09-14'
    AND b.starttime < '2012-09-15'
  ) dsub
WHERE dsub.cost > 30
ORDER BY dsub.cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

/* 
replace the following to go from SQL to SQLite3:
DISTINCT CONCAT(st.year, ' ', st.month)
DISTINCT st.year || ' ' || st.month

SUBSTRING(b.starttime, 6, 2) AS month
SUBSTR(b.starttime, 6, 2) AS month

SUBSTRING(b.starttime, 1, 4) AS year
SUBSTR(b.starttime, 1, 4) AS year
*/
SELECT st.fname AS facility_name,
       (SUM(st.rev) - of.initialoutlay - (of.monthlymaintenance * COUNT(DISTINCT CONCAT(st.year, ' ', -- here
	   st.month)))) AS total_revenue     
FROM(
	SELECT f.name AS fname,
			b.bookid,
	       SUBSTRING(b.starttime, 6, 2) AS month, -- here
       	   SUBSTRING(b.starttime, 1, 4) AS year, -- here
	CASE WHEN b.memid = 0 THEN b.slots * f.guestcost
	ELSE b.slots * f.membercost END AS rev
	FROM Bookings b
	JOIN Facilities f
	ON b.facid = f.facid
	) st
JOIN Facilities of
ON st.fname = of.name
GROUP BY facility_name
HAVING total_revenue < 1000
ORDER BY total_revenue
















































