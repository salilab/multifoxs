#!/usr/bin/perl -w

package UTIL;

use strict;
use CGI qw/:standard/;

sub printHeader{
print "<html>
<head>
<title>FOXS Server: An Automatic Server for SAXS profile computation</title>
  <meta name=\"KEYWORDS\"
  content=\"Small Angle X-Ray Scattering, SAXS, Debye formula, SAXS profile, SAXS fit, structure, molecule, protein\">
  <meta name=\"DESCRIPTION\" content=\"FOXS SAXS computation\">
<link rel=\"stylesheet\" type=\"text/css\" href=\"/foxs/css/server.css\">
<script src=\"http://salilab.org/js/salilab.js\" type=\"text/javascript\"></script>
</head>

<body>
<div id=\"container\">
<div id=\"header1\">
  <table>
  <tbody>
    <tr>
      <td halign=\"left\">
      <table><tr><td>
      <img src=\"/foxs/logo.png\" align = \"left\" height = 80>
      </td></tr>
      <tr><td>
      <h3>Fast SAXS Profile Computation with Debye Formula</h3>
      </td></tr></table>
      </td>
      <td halign=\"right\"><img src=\"/foxs/logo2.gif\" height =80></td>
    </tr>
  </tbody>
  </table>
</div>
<div id=\"navigation_lab\">

      &bull;&nbsp; <a href=\"/foxs/about.html\">About FOXS</a>&nbsp;
      &bull;&nbsp; <a href=\"/foxs/index.html\">Web Server</a>&nbsp;
      &bull;&nbsp; <a href=\"/foxs/help.html\">Help</a>&nbsp;
      &bull;&nbsp; <a href=\"/foxs/FAQ.html\">FAQ</a>&nbsp;
      &bull;&nbsp; <a href=\"/foxs/download.html\">Download</a>&nbsp;
      &bull;&nbsp;<a href=\"http://salilab.org\">Sali Lab</a>&nbsp;
      &bull;&nbsp;<a href=\"http://salilab.org/imp\">IMP</a>&nbsp;
      &bull;&nbsp; <a href=\"/foxs/links.html\">Links</a>&nbsp;

</div>
\n
<script type=\"text/javascript\">
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-38584804-1']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>

";
}

sub printFooter {
print "<hr size=2 width=90% align=center>\n";
  print "<p> <p>
<table><tr><td><b> If you use FoXS, please cite: </td></tr><tr><td>
D. Schneidman-Duhovny, M. Hammel, JA. Tainer, and A. Sali. Accurate SAXS profile computation and its assessment by contrast variation experiments. Biophysical Journal 2013. <br>
</td> </tr> <tr><td>
D. Schneidman-Duhovny, M. Hammel, and A. Sali. FoXS: A Web server for Rapid Computation and Fitting of SAXS Profiles. NAR 2010.38 Suppl:W540-4 <br>
</td> </tr> <tr><td>
Contact: <script>escramble(\"dina\",\"salilab.org\")</script><br>
</td></tr>";
  print end_html;
}

sub removeSpecialChars {
  my $str = shift;
  $str =~ s/[^\w,^\d,^\.]//g;
  return $str;
}

sub trimExtension {
  my $str = shift;
  my $size = length $str;
  #trim ".xxx" extension if exists
  if($size > 4 and substr($str, -4, 1) eq '.') {
    $str = substr $str, 0, $size-4;
  }
  return $str;
}

sub trimExtension2 {
  my $str = shift;
  $str =~ s/\.[^.]+$//;
  return $str;
}

sub removeSpaces {
  my $stringWithSpaces = shift;
  my @letters = split(" ",$stringWithSpaces);
  my $stringWithoutSpaces = join("", @letters);
  return $stringWithoutSpaces;
}

sub printInputData {
  my $filename = "data.txt";
  my $runDir = shift;
  open FILE, "<$filename" or die "Can't open file: $filename";
  my @dataFile = <FILE>;
  my $dataLine = $dataFile[0];
  chomp($dataLine);
  my @data = split('\,',$dataLine);

  print "<table width=\"90%\"><tr>
<td><font color=blue>PDB files</td>
<td><font color=blue>Profile file</td>\n";
#<td><font color=blue>User e-mail</td></tr>\n";
#<td><font color=blue>Maximal q value</td>
#<td><font color=blue>Number of points</td>
#<td><font color=blue>Offset used</td></tr>\n";

  print "<tr>";
  for(my $i=0; $i <= $#data-3; $i++) {
    print "<td>";
    my $fieldName = $data[$i];
    $fieldName =~ s/^\s+//;
    if(-e $fieldName) {
      print "<a href = \"/foxs/runs/$runDir/$fieldName\"> $fieldName </a>";
    } else {
      print $fieldName;
    }
    print "</td>";
  }
  print "</tr>
  </tbody>
  </table>
<hr size=2 width=90% align=center>
";
}


sub sendEmail {
  my $dirname = shift;
  my $protFileName = shift;
  my $email = shift;
  my $allosmod = shift;

  my $results_linkname = "http://modbase.compbio.ucsf.edu/foxs/runs/$dirname/";
  my $from_address = "From:foxs\@modbase.compbio.ucsf.edu\n";
  my $to_address = "To:".$email."\n";
  my $subject = "Subject: FoXS results\n";
  if($allosmod) { $subject = "Subject: AllosMod-FoXS-MES results\n"; }
  my $message_body = "Thank you for using our server.\n You can view your results for $protFileName under: \n $results_linkname\n";
  my $sendmail = "/usr/sbin/sendmail -t -v";

  open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
  print SENDMAIL $from_address;
  print SENDMAIL $subject;
  print SENDMAIL $to_address;
  print SENDMAIL "Content-type: text/plain\n\n";
  print SENDMAIL $message_body;
  close(SENDMAIL);
}


sub printCanvas {
print
"<script src=\"/foxs/gnuplot_js/canvastext.js\"></script>
<script src=\"/foxs/gnuplot_js/gnuplot_common.js\"></script>
<script src=\"/foxs/gnuplot_js/gnuplot_dashedlines.js\"></script>
<script src=\"/foxs/gnuplot_js/gnuplot_mouse.js\"></script>
<script type=\"text/javascript\">
var canvas, ctx;
gnuplot.grid_lines = true;
gnuplot.zoomed = false;
gnuplot.active_plot_name = \"gnuplot_canvas\";
gnuplot.active_plot = gnuplot.dummyplot;
gnuplot.dummyplot = function() {};
function gnuplot_canvas( plot ) { gnuplot.active_plot(); };
</script>\n";
}

1;
