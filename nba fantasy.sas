/* NBA Fantasy Models */

libname nba 'D:\NBA\Draft 2018';

%macro import(filename=);

PROC IMPORT DATAFILE= "D:\NBA\Draft 2018\&filename..xlsx"  OUT= nba.&filename.
            DBMS=xlsx replace;
RUN;

%mend;

%macro export(filename=);

proc export data=nba.&filename.
	outfile="D:\NBA\Draft 2018\&filename..xlsx"
	dbms=xlsx;
run;

%mend;

%import(filename=NBA_2018_advanced);
%import(filename=Draft_2018_Projections);

%macro sort(filename=, sort1=, sort2=);
proc sort data=nba.&filename.;
	by &sort1. &sort2.;
run;
%mend;

%sort(filename=NBA_2018, sort1=Player, sort2=Tm);

%sort(filename=NBA_2018_advanced, sort1=Player, sort2=Tm);

data nba.draft_merge;
	merge nba.NBA_2018 nba.NBA_2018_advanced;
	by Player Tm;
run;


proc standard data=nba.draft_merge mean=0 std=1 out=nba.std_NBA_2018;
	var FG_ FT_ _3P ORB DRB TRB AST STL BLK TOV PS_G;
run;

data nba.std_NBA_2018;
	set nba.std_NBA_2018;
	Score=sum(FG_, FT_, _3P, TRB, AST, STL, BLK, PS_G);
	keep Player MP PS_G TRB AST BLK FG_ STL FT_ _3P TOV USG_;
run;
proc sort data=nba.std_NBA_2018 out=nba.test;
	by descending score;
run;
data nba.draft;
	set nba.std_NBA_2018;
	keep Player MP PS_G TRB AST BLK FG_ STL FT_ _3P TOV USG_;
run;

proc sort data=nba.draft out=nba.draft_1;
	by DESCENDING AST MP ;
	where MP>15;
run;

proc sort data=nba.draft out=nba.draft_2;
	by DESCENDING TRB ;
	where MP>15;
run;

proc sort data=nba.draft out=nba.draft_3;
	by DESCENDING USG_ MP PS_G TRB BLK TOV MP ;
	where MP>15;
run;


/* Draft 2018 Second Try */

data nba.draft18_1;
	set nba.draft_2018_projections;
	temp1=substr(FG_,1,4);
	temp2=substr(FT_,1,4);
	FGp=inputn(temp1, 4.5);
	FTp=inputn(temp2, 4.5);
run;

proc standard data=nba.draft18_1 mean=0 std=1 out=nba.std_NBA_2018;
	var FGp FTp _3PM TREB AST STL BLK TO PTS;
run;

data nba.punt_AD;
	set nba.std_NBA_2018;
	Score=sum(FG_, FT_, _3P, TRB, AST, STL, BLK, PS_G);
	keep Player MP PS_G TRB AST BLK FG_ STL FT_ _3P TOV USG_;
run;
