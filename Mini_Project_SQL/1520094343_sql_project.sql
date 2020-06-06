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

SELECT distinct name FROM Facilities WHERE membercost not in ('0.0')

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT( DISTINCT name )
FROM Facilities
WHERE membercost
IN ('0.0')

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost < 0.2 * monthlymaintenance and membercost not in ('0.0')

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT *
FROM Facilities
WHERE facid
IN ( 1, 5 )

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

select name,monthlymaintenance, 
case when monthlymaintenance <= 100 then 'cheap'
     when monthlymaintenance > 100 then 'expensive'
end as label
from Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

select firstname, surname from
(
select firstname, surname, 
       rank() over (
         order by joindate desc) as join_rank 
from Members )
where join_rank = 1
/*syntax error???*/

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

select distinct b.name, concat(c.firstname,c.surname) as member_name
from Bookings a
left join Facilities b on a.facid = b.facid
left join Members c on a.memid = c.memid
where b.name in ('Tennis Court 1','Tennis Court 2') and a.memid <> 0
order by concat(c.firstname,c.surname)

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

select c.name,concat(b.firstname,b.surname) as person_name, 
(case when a.memid = 0 then c.guestcost else c.membercost end)*a.slots
as cost

from Bookings a
left join Members b on a.memid = b.memid
left join Facilities c on a.facid = c.facid
where substring(a.starttime,1,10)  in ('2012-09-14')
and (case when a.memid = 0 then c.guestcost else c.membercost end)*a.slots > 30
order by (case when a.memid = 0 then c.guestcost else c.membercost end)*a.slots desc


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
select x.name,concat(x.firstname,x.surname) as person_name, 
x.cost

from 
(select 
 a.starttime, a.memid, c.guestcost,
 c.membercost, a.slots, c.name, b.firstname, b.surname,
(case when a.memid = 0 then guestcost else membercost end)*a.slots as cost
       
from Bookings a
left join Members b on a.memid = b.memid
left join Facilities c on a.facid = c.facid) x

where substring(x.starttime,1,10)  in ('2012-09-14')
and x.cost > 30
order by x.cost desc

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

select * from (

select x.name,sum(x.revenue) as revenue_total

from
(select a.facid, b.name, 
 (case when a.memid = 0 then b.guestcost else b.membercost end) * a.slots as revenue
 
 from Bookings a
 left join Facilities b on a.facid = b.facid
 left join Members c on a.memid = c.memid
 
 )x
group by x.name
order by sum(x.revenue)) as a where a.revenue_total < 1000


