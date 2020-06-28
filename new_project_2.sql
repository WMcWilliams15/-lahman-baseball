 Question 1: 		What range of years does the provided database cover?

SOURCES :: 		peoples table, also look at ER diagram to see what other table might apply.
      
DIMENSIONS ::		what are the span of decades
       
FACTS ::			min year and max year
        
FILTERS :: 		agg function in the select statement, MIN() and MAX()
        
DESCRIPTION ::	only using 3 main tables from db
        
ANSWER ::			1870's - 2010's, 1871,2016

SELECT MIN(debut), MAX(finalgame)
FROM people;



QUESTION ::	2	Find the name and height of the shortest player in the database. 
					How many games did he play in? 
					What is the name of the team for which he played?
        
SOURCES ::		people table, appearance table, ive started looking at the data dictionary to view the columns.
   
DIMENSIONS ::	Height of every player
       
FACTS ::		MIN(height)
     
FILTERS ::		set playerid to Edward Carls id to only get the results i need.

DESCRIPTION ::

ANSWER ::			name: Edward Carl Gaedel
					height: 43	
					games played: 1 	
					team: SLA


SELECT namefirst, namelast, MIN(height), p.playerid, g_all, teamid
FROM people AS p
INNER JOIN appearances AS a
ON p.playerid = a.playerid
WHERE a.playerid = 'gaedeed01'
GROUP BY namegiven, p.playerid, g_all, teamid
ORDER BY MIN(height);

subquery in the where clause
try to make one query

Question::	3	Find all players in the database who played at Vanderbilt University. 
				Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
				Sort this list in descending order by the total salary earned. 
				Which Vanderbilt player earned the most money in the majors?		
 
SOURCES :: 		schools, collegeplaying, salaries, people 
       
DIMENSIONS ::	salary range for players who played at vanderbilt
       
FACTS ::		MAX(salary)
        
FILTERS :: 		played at vanderbilt
        
DESCRIPTION ::
        
ANSWER ::			David Price, $245553888					


SELECT schoolid
FROM collegeplaying   
GROUP BY schoolid
order by schoolid;				-- this is how i found the way vanderbilt is spelled.  (vandy)


SELECT DISTINCT(playerid)
FROM collegeplaying
WHERE schoolid = 'vandy';		-- this is the list of players who played college ball at vandy.

SELECT DISTINCT(playerid),
		namefirst,
		namelast,
		SUM(salary)
FROM collegeplaying
INNER JOIN people
USING (playerid)				-- this query gives me the list of players total salaries
INNER JOIN salaries
USING (playerid)
WHERE schoolid = 'vandy'
GROUP BY playerid, namefirst, namelast
ORDER BY SUM(salary) DESC;

make sure casting salary as numeric money


QUESTION ::	4
	    		Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield" 
				those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
				Determine the number of putouts made by each of these three groups in 2016.

SOURCES ::		feilding table
        
DIMENSIONS ::	positions
        
FACTS ::		total putouts 
        
FILTERS ::
        
DESCRIPTION ::
        
ANSWER ::
        OUTFIELD: 29560		INFIELD: 58934 	BATTERY: 41424 


WITH cte as(
	SELECT pos,
			po,
			yearid,
			case when pos in ('OF') then 'Outfield'
				when pos in ('SS', '1B', '2B', '3B') then 'Infield'
				when pos in ('P', 'C') then 'Battery'
				else 'unknown' 	end as position
	from fielding)

SELECT SUM(po),
		yearid,
		position
FROM cte
WHERE yearid = 2016
GROUP BY yearid, position;
	


QUESTION ::	5
        		Find the average number of strikeouts per game by decade since 1920. 
				Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SOURCES ::
        		Batting
DIMENSIONS ::
        		decades
FACTS ::
                total strikeouts per game, total homeruns per game, years >= 1920.
DESCRIPTION ::
        
ANSWER ::		Homeruns and strikeouts increased every decade.

				decade	so		hr
				201		15.04	1.97
				200		13.12	2.15
				199		12.30	1.91
				198		10.73	1.62
				197		10.29	1.49
				196		11.43	1.64
				195		8.80	1.69
				194		7.10	1.05
				193		6.63	1.09
				192		5.63	0.80
        

SELECT 	yearid / 10 AS decade, 
		ROUND(sum(so)/(sum(g)::numeric/2), 2),
		ROUND(sum(hr)/(sum(g)::numeric/2), 2)	-- divide games by two because of the way the data is entered. two teams play in one game.
from teams
where (yearid / 10) >= 192
GROUP BY decade
ORDER BY decade desc



QUESTION ::	6
        		Find the player who had the most success stealing bases in 2016, 
				where success is measured as the percentage of stolen base attempts which are successful. 
				(A stolen base attempt results either in a stolen base or being caught stealing.) 
				Consider only players who attempted at least 20 stolen bases.
SOURCES ::
        		Batting table,
DIMENSIONS ::
        		player
FACTS ::
				percentage of stole bases, attempts = (sb + cs)
FILTERS ::
				year = 2016, attempts > 20
DESCRIPTION ::
        
ANSWER ::		91.3%		chris owin
        

SELECT sb,
		cs,
		playerid,		--concat names
		ROUND(sb/(cs+sb):: numeric, 3) AS success
FROM batting										-- join people on playerid. 
WHERE yearid = 2016 AND (sb + cs) >= 20
GROUP BY sb, cs, playerid
ORDER BY success desc;

concat and join should make this one query

select concat(namefirst, ' ', namelast)
from people
where playerid = 'owingch01'



QUESTION ::	7

				From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
				What is the smallest number of wins for a team that did win the world series? 
				Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. 
				Then redo your query, excluding the problem year. 
				How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
SOURCES ::
        		Teams table
DIMENSIONS ::
				wins for teams by year
FACTS ::
				MAX(w), percentage of teams that had most wins for a year and won world series
FILTERS ::
				year = 1970-2016, won a world seires
DESCRIPTION ::
       
ANSWER ::
        		2001 Seattle Marianers 	W:116 	L:46 	Worldseries: Lost
				1981 LAN				W: 63	L:47	Worldseries: Won
				Why did 1981 LAN win the Series... MLB strike
				96 percent of the time max win team went on to win the series


SELECT 	max(w),
		teamid
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
AND yearid <> 1981
AND wswin = 'Y'
group by yearid, teamid;


with wsw as(
			select *
			from teams
			where yearid between 1970 and 2016)
select 	max(w),
		wsw.wswin
from wsw
where wswin = 'Y'
group by yearid, wsw.wswin


select ROUND(45/47:: numeric, 2)


select *
from teams

with max_wins as(
	select 	max(w),
			yearid
	from teams
	where yearid between 1970 and 2016
	group by yearid)


with ws_wins as ()



select *
		casewhn  
select 	w,
		yearid
from teams
where yearid between 1970 and 2016
and wswin = 'Y'

QUESTION ::	8

				Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 
				(where average attendance is defined as total attendance divided by number of games).
				Only consider parks where there were at least 10 games played. 
				Report the park name, team name, and average attendance. 
				Repeat for the lowest 5 average attendance.
SOURCES ::
        		homegames table
DIMENSIONS ::
				parks attendance
FACTS ::
        		top 5 avgerage attendance per game, bottom 5 average attendance per game
FILTERS ::
        		games >= 10, year = 2016
DESCRIPTION ::
        ...
ANSWER ::
							HIGHEST
				team			g	att.	avg
				"LAN"	"LOS03"	81	3703312	45719
				"SLN"	"STL10"	81	3444490	42524
				"TOR"	"TOR02"	81	3392099	41877
				"SFN"	"SFO03"	81	3365256	41546
				"CHN"	"CHI11"	81	3232420	39906

							LOWEST
				team			g	att.	avg			
				"TBA"	"STP01"	81	1286163	15878
				"OAK"	"OAK01"	81	1521506	18784
				"CLE"	"CLE08"	81	1591667	19650
				"MIA"	"MIA02"	80	1712417	21405
				"CHA"	"CHI12"	81	1746293	21559


select 	team,
		park,
		games,
		attendance,
		(attendance/games) :: numeric
from homegames
where year = 2016
and games >= 10
group by attendance, games, team, park
order by attendance;

try using a union of two subquerys in the from clause, to make one query

QUESTION ::	9

				Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
				Give their full name and the teams that they were managing when they won the award.
SOURCES ::
        		Teams table
DIMENSIONS ::
        		Awards given to managers
FACTS ::
        		lgid = 'AL' AND lgid = 'NL', awardid = 'TSN Manager of the Year'
FILTERS ::
        		
DESCRIPTION ::
        
ANSWER ::		"Davey Johnson"	"BAL"	1997
				"Davey Johnson"	"WAS"	2012
				
				"Jim Leyland"	"PIT"	1988
				"Jim Leyland"	"PIT"	1990
				"Jim Leyland"	"PIT"	1992
				"Jim Leyland"	"DET"	2006
			

with tsn as(
			SELECT *
			FROM awardsmanagers
			where awardid = 'TSN Manager of the Year')
				
SELECT*
from tsn
where lgid = 'NL'
or lgid ='AL'
ORDER BY playerid;

johnsda02	97	12
leylaji99 	06  92  90  88	


select 	CONCAT(people.namefirst, ' ', people.namelast) AS full_name,
		managers.teamid,
		managers.yearid
from people
inner join managers
using (playerid)
where managers.playerid = 'johnsda02'
and yearid in (1997, 2012)
order by full_name;


select 	CONCAT(people.namefirst, ' ', people.namelast) AS full_name,
		managers.teamid,
		managers.yearid
from people
inner join managers
using (playerid)
where managers.playerid = 'leylaji99'
and yearid in (1988, 1990, 1992, 2006)
order by full_name

	
	
