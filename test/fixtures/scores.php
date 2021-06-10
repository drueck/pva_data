<!DOCTYPE html>
<html lang="en">
<head>
  <title>Portland Volleyball Association</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="shortcut icon" href="favicon.ico" />

  <!-- Latest compiled and minified CSS -->
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">

  <!--[if lt IE 9]>
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/html5shiv/3.7.3/html5shiv.js">
    </script>
  <![endif]-->
  <link rel="stylesheet" href="/styles/pva.css?2.0.8">


  <link href="https://fonts.googleapis.com/css?family=Montserrat:400,700|Open+Sans:400,700" rel="stylesheet">
  <script language="javascript">
    function getE(handle, domain) {
      return handle + '@' + domain;
    }
    function getMailto(handle, domain)
    {
      document.write('<a href="mailto:' + handle + '@' + domain + '">' + handle + '@' + domain + '</a>.');
    }
  </script>
  <script>
    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
      (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
      m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
    })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

    ga('create', 'UA-82904877-1', 'auto');
    ga('send', 'pageview');

  </script>
</head>

<body>
      <nav class="navbar navbar-default navbar-static-top">
    <div class="container-fluid">
      <div class="navbar-header">
        <button type="button" class="collapsed navbar-toggle" data-toggle="collapse" data-target="#pva-navbar-collapse" aria-expanded="false">
          <span class="sr-only">Toggle navigation</span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
        </button>
        <a href="/" class="navbar-brand">
          <img src="/images/header-logo.svg" style="max-height: 100%;width: 80px; margin: 5px 10px;" />
        </a>
      </div>
      <div id="pva-navbar-collapse" class="collapse navbar-collapse">
        <ul class="nav navbar-nav">
          <li>
            <a href="/">Home</a>
          </li>
          <li>
            <a href="/schedules.php">Schedules</a>
          </li>
          <li>
            <a href="/scores.php">Scores</a>
          </li>
          <li>
            <a href="/standings.php">Standings</a>
          </li>
          <li>
            <a href="/gyms.php">Gyms</a>
          </li>
          <li>
            <a href="/rules.php">Rules</a>
          </li>
          <li>
            <a href="/contact.php">Contact</a>
          </li>
          <li>
            <a href="/checkin.php">COVID Check-In</a>
          </li>
          <li class="dropdown">
            <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">More <span class="caret"></span></a>
            <ul class="dropdown-menu">
              <li>
                <a href="/winners.php">Winners</a>
              </li>
              <li>
                <a href="/about.php">About</a>
              </li>
              <li>
                <a href="/links.php">Links</a>
              </li>
              <li>
                <a href="/archives.php">News Archives</a>
              </li>
              <li>
                <a href="http://www.facebook.com/PortlandVolleyballAssociation" target="_blank">Facebook</a>
              </li>
            </ul>
          </li>
        </ul>
      </div>
    </div>
  </nav><div id="content" class="container"><h1>Scores for completed games</h1>

<p>To filter, choose one of the options below, and click "Filter".</p>

<form class="form-inline" name="sort" method="post">
  <div class="form-group">
	<select class="form-control" name="teams" onchange="document.sort.leagues.selectedIndex = 0;">
	<option value="">-- Select team --</option>
<option value="1928">2Legit2Hit (Coed Grass Quads)</option><option value="1914">A&M's (Womens Grass Quads A)</option><option value="1925">ALL ABOUT THAT ACE (Womens Grass Quads B)</option><option value="1921">Attack Pack (Womens Grass Quads B)</option><option value="1930">Awkward High Fives (Coed Grass Quads)</option><option value="1920">Ball Busters (Womens Grass Quads B)</option><option value="1919">Block and Awe (Womens Sand Quads)</option><option value="1929">BSB (Womens Grass Quads A)</option><option value="1910">Bump n' Grind (Coed Grass Quads)</option><option value="1904">Bumptown Like Stumptown (Womens Grass Quads B)</option><option value="1932">CG Girls (Womens Sand Quads)</option><option value="1908">Crafty Monkeys (Womens Grass Quads A)</option><option value="1933">Free Agents (Coed Grass Quads)</option><option value="1917">Grass Hurts (Womens Grass Quads B)</option><option value="1900">Grass Stain (Womens Grass Quads B)</option><option value="1901">Have Balls Will Travel (Coed Grass Quads)</option><option value="1903">Hop Heads (Coed Grass Quads)</option><option value="1899">LADYBALLS! (Womens Grass Quads A)</option><option value="1905">Lollipop Girls (Womens Grass Quads A)</option><option value="1927">Net Gain  (Womens Grass Quads B)</option><option value="1909">OverServed (Womens Grass Quads A)</option><option value="1912">Pancakes (Womens Sand Quads)</option><option value="1916">Quad Damn (Womens Grass Quads A)</option><option value="1902">Rhombus (Coed Grass Quads)</option><option value="1918">Sandbags (Womens Sand Quads)</option><option value="1911">Sandy Pops (Womens Sand Quads)</option><option value="1926">Serve-ivors (Womens Sand Quads)</option><option value="1907">Shindigs (Womens Grass Quads A)</option><option value="1924">SMASH (Womens Grass Quads B)</option><option value="1906">Spike Force (Coed Grass Quads)</option><option value="1931">Team 2 (Womens Grass Quads A)</option><option value="1935">Thing 1 (Womens Sand Quads)</option><option value="1934">Thing 1 (Womens Grass Quads A)</option><option value="1913">Waffles (Womens Sand Quads)</option></select>
</div>
<div class="form-group">
<select class="form-control" name="leagues" onchange="document.sort.teams.selectedIndex = 0;">
<option value="">-- Select league --</option><option value="129">Coed Grass Quads</option><option value="127">Womens Grass Quads A</option><option value="128">Womens Grass Quads B</option><option value="130">Womens Sand Quads</option></select>
</div>
<input type="submit" value="Filter" class="btn btn-default" />
</form>
<br />
<div class="table-responsive">
<table class="table table-striped table-condensed">
<tr>
<th>Date</th>
<th>Time</th>
<th>League</th>
<th>Home</th>
<th>Visitor</th>
<th>Game 1</th>
<th>Game 2</th>
<th>Game 3</th>
</tr>
<tr>
<td colspan="5">
</td>
<td colspan="3">
<em><small>Scores are shown 'home - visitor'</small></em>
</td>
</tr>

<tr>
<td>6/07 (Mon)</td><td>6:30</td>
<td>Womens Grass Quads B</td>
<td><span class="">Grass Hurts</span></td>
<td><span class="scores-table__team--winning-team">Attack Pack</span></td>
<td class="scores-table__game-score">8 - 21</td>
<td class="scores-table__game-score">21 - 19</td>
<td class="scores-table__game-score">8 - 15</td>
</tr>
<tr>
<td>6/07 (Mon)</td><td>6:30</td>
<td>Womens Grass Quads A</td>
<td><span class="">Crafty Monkeys</span></td>
<td><span class="scores-table__team--winning-team">Quad Damn</span></td>
<td class="scores-table__game-score">21 - 13</td>
<td class="scores-table__game-score">17 - 21</td>
<td class="scores-table__game-score">7 - 15</td>
</tr>
<tr>
<td>6/07 (Mon)</td><td>6:30</td>
<td>Womens Grass Quads A</td>
<td><span class="">OverServed</span></td>
<td><span class="scores-table__team--winning-team">A&M's</span></td>
<td class="scores-table__game-score">11 - 21</td>
<td class="scores-table__game-score">12 - 21</td>
<td class="scores-table__game-score">12 - 15</td>
</tr>
<tr>
<td>6/07 (Mon)</td><td>6:30</td>
<td>Womens Grass Quads A</td>
<td><span class="scores-table__team--winning-team">Lollipop Girls</span></td>
<td><span class="">Team 2</span></td>
<td class="scores-table__game-score">21 - 18</td>
<td class="scores-table__game-score">21 - 14</td>
<td class="scores-table__game-score">15 - 9</td>
</tr>
<tr>
<td>6/07 (Mon)</td><td>6:30</td>
<td>Womens Grass Quads A</td>
<td><span class="scores-table__team--winning-team">LADYBALLS!</span></td>
<td><span class="">Thing 1</span></td>
<td class="scores-table__game-score">21 - 19</td>
<td class="scores-table__game-score">21 - 16</td>
<td class="scores-table__game-score">13 - 15</td>
</tr>
<tr>
<td>6/07 (Mon)</td><td>6:30</td>
<td>Womens Grass Quads B</td>
<td><span class="">Ball Busters</span></td>
<td><span class="scores-table__team--winning-team">ALL ABOUT THAT ACE</span></td>
<td class="scores-table__game-score">5 - 21</td>
<td class="scores-table__game-score">21 - 7</td>
<td class="scores-table__game-score">6 - 15</td>
</tr>
<tr>
<td>6/07 (Mon)</td><td>6:30</td>
<td>Womens Grass Quads B</td>
<td><span class="scores-table__team--winning-team">Grass Stain</span></td>
<td><span class="">Net Gain </span></td>
<td class="scores-table__game-score">21 - 18</td>
<td class="scores-table__game-score">21 - 15</td>
<td class="scores-table__game-score">15 - 13</td>
</tr>
<tr>
<td>6/07 (Mon)</td><td>6:30</td>
<td>Womens Grass Quads B</td>
<td><span class="">Bumptown Like Stumptown</span></td>
<td><span class="scores-table__team--winning-team">SMASH</span></td>
<td class="scores-table__game-score">19 - 21</td>
<td class="scores-table__game-score">15 - 21</td>
<td class="scores-table__game-score">15 - 11</td>
</tr>
<tr>
<td>6/07 (Mon)</td><td>7:30</td>
<td>Womens Grass Quads B</td>
<td><span class="scores-table__team--winning-team">Grass Hurts</span></td>
<td><span class="">Ball Busters</span></td>
<td class="scores-table__game-score">21 - 19</td>
<td class="scores-table__game-score">21 - 14</td>
<td class="scores-table__game-score">15 - 9</td>
</tr>
<tr>
<td>6/07 (Mon)</td><td>7:30</td>
<td>Womens Grass Quads B</td>
<td><span class="">SMASH</span></td>
<td><span class="scores-table__team--winning-team">Grass Stain</span></td>
<td class="scores-table__game-score">21 - 10</td>
<td class="scores-table__game-score">20 - 22</td>
<td class="scores-table__game-score">9 - 15</td>
</tr>
<tr>
<td>6/07 (Mon)</td><td>7:30</td>
<td>Womens Grass Quads B</td>
<td><span class="">Attack Pack</span></td>
<td><span class="scores-table__team--winning-team">Bumptown Like Stumptown</span></td>
<td class="scores-table__game-score">19 - 21</td>
<td class="scores-table__game-score">10 - 21</td>
<td class="scores-table__game-score">15 - 11</td>
</tr>
<tr>
<td>6/07 (Mon)</td><td>7:30</td>
<td>Womens Grass Quads A</td>
<td><span class="">BSB</span></td>
<td><span class="scores-table__team--winning-team">Thing 1</span></td>
<td class="scores-table__game-score">21 - 11</td>
<td class="scores-table__game-score">19 - 21</td>
<td class="scores-table__game-score">12 - 15</td>
</tr>
<tr>
<td>6/07 (Mon)</td><td>7:30</td>
<td>Womens Grass Quads A</td>
<td><span class="">OverServed</span></td>
<td><span class="scores-table__team--winning-team">Crafty Monkeys</span></td>
<td class="scores-table__game-score">23 - 25</td>
<td class="scores-table__game-score">17 - 21</td>
<td class="scores-table__game-score">11 - 15</td>
</tr>
<tr>
<td>6/07 (Mon)</td><td>7:30</td>
<td>Womens Grass Quads B</td>
<td><span class="scores-table__team--winning-team">ALL ABOUT THAT ACE</span></td>
<td><span class="">Net Gain </span></td>
<td class="scores-table__game-score">21 - 15</td>
<td class="scores-table__game-score">21 - 11</td>
<td class="scores-table__game-score">15 - 10</td>
</tr>
<tr>
<td>6/07 (Mon)</td><td>7:30</td>
<td>Womens Grass Quads A</td>
<td><span class="">Team 2</span></td>
<td><span class="scores-table__team--winning-team">LADYBALLS!</span></td>
<td class="scores-table__game-score">16 - 21</td>
<td class="scores-table__game-score">10 - 21</td>
<td class="scores-table__game-score">11 - 15</td>
</tr>
<tr>
<td>6/07 (Mon)</td><td>7:30</td>
<td>Womens Grass Quads A</td>
<td><span class="scores-table__team--winning-team">A&M's</span></td>
<td><span class="">Shindigs</span></td>
<td class="scores-table__game-score">18 - 21</td>
<td class="scores-table__game-score">21 - 10</td>
<td class="scores-table__game-score">15 - 8</td>
</tr>
<tr>
<td>6/08 (Tue)</td><td>6:30</td>
<td>Coed Grass Quads</td>
<td><span class="scores-table__team--winning-team">Spike Force</span></td>
<td><span class="">Bump n' Grind</span></td>
<td class="scores-table__game-score">21 - 7</td>
<td class="scores-table__game-score">21 - 7</td>
<td class="scores-table__game-score">15 - 8</td>
</tr>
<tr>
<td>6/08 (Tue)</td><td>6:30</td>
<td>Coed Grass Quads</td>
<td><span class="">Rhombus</span></td>
<td><span class="scores-table__team--winning-team">Awkward High Fives</span></td>
<td class="scores-table__game-score">21 - 13</td>
<td class="scores-table__game-score">16 - 21</td>
<td class="scores-table__game-score">11 - 15</td>
</tr>
<tr>
<td>6/08 (Tue)</td><td>6:30</td>
<td>Coed Grass Quads</td>
<td><span class="scores-table__team--winning-team">Have Balls Will Travel</span></td>
<td><span class="">Free Agents</span></td>
<td class="scores-table__game-score">21 - 7</td>
<td class="scores-table__game-score">21 - 10</td>
<td class="scores-table__game-score">15 - 6</td>
</tr>
<tr>
<td>6/08 (Tue)</td><td>6:30</td>
<td>Coed Grass Quads</td>
<td><span class="scores-table__team--winning-team">Hop Heads</span></td>
<td><span class="">2Legit2Hit</span></td>
<td class="scores-table__game-score">21 - 15</td>
<td class="scores-table__game-score">21 - 10</td>
<td class="scores-table__game-score">15 - 11</td>
</tr>
<tr>
<td>6/08 (Tue)</td><td>7:30</td>
<td>Coed Grass Quads</td>
<td><span class="">Spike Force</span></td>
<td><span class="scores-table__team--winning-team">Hop Heads</span></td>
<td class="scores-table__game-score">23 - 21</td>
<td class="scores-table__game-score">16 - 21</td>
<td class="scores-table__game-score">12 - 15</td>
</tr>
<tr>
<td>6/08 (Tue)</td><td>7:30</td>
<td>Coed Grass Quads</td>
<td><span class="scores-table__team--winning-team">2Legit2Hit</span></td>
<td><span class="">Free Agents</span></td>
<td class="scores-table__game-score">21 - 15</td>
<td class="scores-table__game-score">21 - 16</td>
<td class="scores-table__game-score">15 - 6</td>
</tr>
<tr>
<td>6/08 (Tue)</td><td>7:30</td>
<td>Coed Grass Quads</td>
<td><span class="">Awkward High Fives</span></td>
<td><span class="scores-table__team--winning-team">Have Balls Will Travel</span></td>
<td class="scores-table__game-score">18 - 21</td>
<td class="scores-table__game-score">21 - 19</td>
<td class="scores-table__game-score">8 - 15</td>
</tr>
<tr>
<td>6/08 (Tue)</td><td>7:30</td>
<td>Coed Grass Quads</td>
<td><span class="">Bump n' Grind</span></td>
<td><span class="scores-table__team--winning-team">Rhombus</span></td>
<td class="scores-table__game-score">3 - 21</td>
<td class="scores-table__game-score">5 - 21</td>
<td class="scores-table__game-score">3 - 15</td>
</tr>
<tr>
<td>6/09 (Wed)</td><td>6:30</td>
<td>Womens Sand Quads</td>
<td><span class="">Sandbags</span></td>
<td><span class="scores-table__team--winning-team">Block and Awe</span></td>
<td class="scores-table__game-score">6 - 21</td>
<td class="scores-table__game-score">24 - 22</td>
<td class="scores-table__game-score">10 - 15</td>
</tr>
<tr>
<td>6/09 (Wed)</td><td>7:30</td>
<td>Womens Sand Quads</td>
<td><span class="">Sandbags</span></td>
<td><span class="scores-table__team--winning-team">Waffles</span></td>
<td class="scores-table__game-score">21 - 16</td>
<td class="scores-table__game-score">14 - 21</td>
<td class="scores-table__game-score">14 - 16</td>
</tr>

</table>
</div>

<br>
			<div align="center"><a href="http://www.parks.ci.portland.or.us/Default.htm" target="_blank"><img src="/images/logo_ppr.jpg" width=120 alt="" border="0"></a></div>

<!-- Latest compiled and minified JavaScript -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>

</body>
</html>
