package multifoxs;
use saliweb::frontend;
use strict;

use FindBin;
use File::Copy;


our @ISA = "saliweb::frontend";

sub _display_content {
  my ($self, $content) = @_;
  print $content;
}

sub _display_web_page {
  my ($self, $content) = @_;
  my $prefix = $self->start_html("/foxs/css/server.css") . "<div id='container'>" . $self->get_header();
  my $suffix = $self->get_footer() . "</div>\n" . $self->end_html;
  my $navigation = $self->get_navigation_lab();
  print $prefix;
  print $navigation;
  $self->_display_content($content);
  print $suffix;
}

sub get_help_page {
  my ($self, $display_type) = @_;
  my $file;
  if ($display_type eq "contact") {
    $self->set_page_title("Contact");
    $file = "contact.txt";
  } elsif ($display_type eq "news") {
    $self->set_page_title("News");
    $file = "news.txt";
  } elsif ($display_type eq "about") {
    $self->set_page_title("Method Description");
    $file = "about.txt";
  } elsif ($display_type eq "FAQ") {
    $self->set_page_title("FAQ");
    $file = "FAQ.txt";
  } elsif ($display_type eq "links") {
    $self->set_page_title("links");
    $file = "links.txt";
  } elsif ($display_type eq "download") {
    $self->set_page_title("download");
    $file = "download.txt";
  } else {
    $file = "help.txt";
  }
  return $self->get_text_file($file);
}


sub new {
    return saliweb::frontend::new(@_, "##CONFIG##");
}

sub get_navigation_lab {
  return "<div id=\"navigation_lab\">
      &bull;&nbsp; <a href=\"https://modbase.compbio.ucsf.edu/multifoxs/help.cgi?type=about\">About MultiFoXS</a>&nbsp;
      &bull;&nbsp; <a href=\"https://modbase.compbio.ucsf.edu/multifoxs\">Web Server</a>&nbsp;
      &bull;&nbsp; <a href=\"https://modbase.compbio.ucsf.edu/multifoxs/help.cgi?type=help\">Help</a>&nbsp;
      &bull;&nbsp; <a href=\"https://modbase.compbio.ucsf.edu/multifoxs/help.cgi?type=FAQ\">FAQ</a>&nbsp;
      &bull;&nbsp; <a href=\"https://modbase.compbio.ucsf.edu/multifoxs/help.cgi?type=download\">Download</a>&nbsp;
      &bull;&nbsp; <a href=\"https://salilab.org/foxs\">FoXS</a>&nbsp;
      &bull;&nbsp; <a href=\"https://salilab.org\">Sali Lab</a>&nbsp;
      &bull;&nbsp; <a href=\"https://salilab.org/imp\">IMP</a>&nbsp;
      &bull;&nbsp; <a href=\"https://modbase.compbio.ucsf.edu/multifoxs/help.cgi?type=links\">Links</a>&nbsp;</div>\n";
}

sub get_navigation_links {
    my $self = shift;
    my $q = $self->cgi;
    return [
        $q->a({-href=>$self->index_url}, "MultiFoXS Home"),
        $q->a({-href=>$self->queue_url}, "MultiFoXS Current queue"),
        $q->a({-href=>$self->help_url}, "MultiFoXS Help"),
        $q->a({-href=>$self->contact_url}, "MultiFoXS Contact")
        ];
}

sub get_project_menu {
    # TODO
  return "";
}

sub get_header {
  return "<div id='header1'>  
    <table> <tbody> <tr> <td align='left'>
                         <table><tr><td><img src=\"//modbase.compbio.ucsf.edu/multifoxs/html/logo.png\" alt='Logo' align = 'right' height = '60'/></td></tr>
                                <tr><td><h3><font color='#B22222'> Multi-state modeling with SAXS profiles </font> </h3> </td></tr></table>
                         </td>
                         <td align='right'><img src=\"//salilab.org/foxsdock/logo2.gif\" alt='Profile' height = '90'/></td></tr>
  </tbody> </table></div>\n";
}


sub get_footer {
  my $self = shift;
  return "<hr size='2' width=\"80%\"/>\n
<table><tr><td align='left'> If you use MultiFoXS, please cite: </td> </tr></table>
<div id='address'>
D. Schneidman-Duhovny, M. Hammel, JA. Tainer, and A. Sali. FoXS, FoXSDock and MultiFoXS: Single-state and multi-state structural modeling of proteins and their complexes based on SAXS profiles. NAR 2016 [ <a href = \"//doi.org/10.1093/nar/gkw389\"> FREE Full Text </a> ]<br />
Contact: <script type=\"text/javascript\">escramble(\"dina\",\"salilab.org\")</script></div>
<p>MultiFoXS version $self->version_link</p>\n";
}

sub get_index_page {
  my $self = shift;
  my $q = $self->cgi;

  return

  $q->start_form({-name=>"multifoxsform", -method=>"post", -action=>$self->submit_url}) .

  $q->start_table({ -cellpadding=>5, -cellspacing=>0}) .
    $q->Tr($q->td('Type PDB code for protein or upload file in PDB format  ' . $q->a({-href => $self->help_url . "#sampleinput"}, 'sample input files'))) . $q->end_table .

  $q->start_table({ -border=>0, -cellpadding=>5, -cellspacing=>0, -width=>'99%'}) .
    $q->Tr($q->td({ -align=>'left'}, [$q->a({-href => $self->help_url . "#protein"}, $q->b('Input protein'))]) ,
           $q->td({ -align=>'left'}, [$q->textfield({-name=>'pdbcode', -maxlength => 10, -size => 10}) .
                  ' (PDB:chainId e.g. 2kai:AB)']),
           $q->td({ -align=>'left'}, [$q->b('or') . ' upload file: ' . $q->filefield({-name=>'pdbfile', -size => 10})])) .

    $q->Tr($q->td({ -align=>'left'}, [$q->a({-href => $self->help_url . "#flexres"}, $q->b('Flexible residues'))]),
           $q->td({ -align=>'left'}, [$q->filefield({-name=>'hingefile', -size => 10})])) .

    $q->Tr($q->td({ -align=>'left'}, [$q->a({-href => $self->help_url . "#profile"}, $q->b('SAXS profile'))]),
           $q->td({ -align=>'left'}, [$q->filefield({-name=>'saxsfile', -size => 10})])) .

    $q->Tr($q->td({ -align=>'left'}, [$q->a({-href => $self->help_url . "#email"}, $q->b('e-mail address'))]),
           $q->td({ -align=>'left'}, [$q->textfield({-name => 'email'})]),
           $q->td({ -align=>'left'}, ['(the results are sent to this address, optional)'])) .

    $q->Tr($q->td({ -align=>'left', -colspan => 2}, [$q->submit(-value => 'Submit') . $q->reset(-value => 'Clear')])) .

    $q->Tr($q->td({ -align=>'left', -colspan => 3}, [$q->b('Advanced Parameters')])) .

    $q->Tr($q->td({ -align=>'left'}, [$q->a({-href => $self->help_url . "#jobname"}, 'Job name')]),
           $q->td({ -align=>'left'}, [$q->textfield({-name => 'jobname', -maxlength => 10, -size => 10})])) .

    $q->Tr($q->td({ -align=>'left'}, [$q->a({-href => $self->help_url . "#conectrbs"}, 'Connect rigid bodies')]),
           $q->td({ -align=>'left'}, [$q->filefield({-name=>'connectrbsfile', -size => 10})])) .

    $q->Tr($q->td({ -align=>'left'}, [$q->a({-href => $self->help_url . "#confnumber"}, 'Number of conformations')]),
           $q->td({ -align=>'left'}, [$q->textfield({-name=>'modelsnumber', -value=>100, -maxlength => 5, -size => 5})]),
           $q->td({ -align=>'left'}, ['Use 100 to test your setup, 10,000 for final calculation'])) .

    $q->Tr($q->td({ -align=>'left', -colspan => 2}, [$q->submit(-value => 'Submit') . $q->reset(-value => 'Clear')])) .

  $q->end_table . $q->end_form;

}

sub get_submit_page {
  my $self = shift;
  my $q = $self->cgi;
  print $q->header();

  # Get form parameters
  my $pdbcode  = lc $q->param('pdbcode');
  my $pdbfile = $q->param('pdbfile');
  my $hingefile = $q->param('hingefile');
  my $saxsfile = $q->param('saxsfile');
  my $email = $q->param('email') || "";

  my $jobname = $q->param('jobname');
  my $connectrbsfile = $q->param('connectrbsfile');
  my $modelsnumber = $q->param('modelsnumber');

  # Validate input
  check_optional_email($email);

  if(($modelsnumber !~ /^\d+$/ and $modelsnumber !~ /^\d$/) or $modelsnumber <= 0 or $modelsnumber > 10000) {
    throw saliweb::frontend::InputValidationError("Invalid value for number of models $modelsnumber. Must be > 0 and <= 10000\n");
  }

  #create job directory time_stamp
  if(length $jobname == 0) {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
    $jobname = $sec."_".$min."_".$hour."_".$mday."_".$mon."_".$year;
  }
  my $job = $self->make_job($jobname, $email);
  my $jobdir = $job->directory;

  # input PDB file
  my $pdb_file_uploaded = 0;
  my $pdb_file_name = "";
  if (length $pdbcode > 0) { # pdb code given
    $pdb_file_name = get_pdb_chains($pdbcode, $jobdir);
    $pdb_file_name =~ s/.*[\/\\](.*)/$1/;
  } else { # upload file
    if(length $pdbfile > 0 and length $pdbcode == 0) {
      $pdb_file_uploaded = 1;
      my $upload_filenandle = $q->upload("pdbfile");
      my $file_contents = "";
      my $atoms = 0;
      while (<$upload_filenandle>) {
        if (/^ATOM  /) { $atoms++; } #TODO: HETATM?
        $file_contents .= $_;
      }
      if ($atoms == 0) {
        throw saliweb::frontend::InputValidationError("PDB file contains no ATOM records!");
      }
      $pdb_file_name = "$jobdir/input.pdb";
      open(INPDB, "> $pdb_file_name")
        or throw saliweb::frontend::InternalError("Cannot open $pdb_file_name: $!");
      print INPDB $file_contents;
      close INPDB
        or throw saliweb::frontend::InternalError("Cannot close $pdb_file_name: $!");
      $pdb_file_name = "input.pdb";
    } else {
      throw saliweb::frontend::InputValidationError("Error in input PDB: please specify PDB code or upload file");
    }
  }

  #saxs file
  if(length $saxsfile > 0) {
    my $upload_filehandle = $q->upload("saxsfile");
    open UPLOADFILE, ">$jobdir/iq.dat";
    while ( <$upload_filehandle> ) { print UPLOADFILE; }
    close UPLOADFILE;
    my $filesize = -s "$jobdir/iq.dat";
    if($filesize == 0) {
      throw saliweb::frontend::InputValidationError("You have uploaded an empty profile file: $saxsfile");
    }
    #convert if needed
    `tr '\r' '\n' < iq.dat > iq.dat.tmp`;
    rename("iq.dat.tmp", "iq.dat");
    `dos2unix iq.dat`;
  } else {
    throw saliweb::frontend::InputValidationError("Please upload valid SAXS profile");
  }

  # hinges file
  if(length $hingefile > 0) {
    my $upload_filehandle = $q->upload("hingefile");
    open UPLOADFILE, ">$jobdir/hinges.dat";
    while ( <$upload_filehandle> ) { print UPLOADFILE; }
    close UPLOADFILE;
    my $filesize = -s "$jobdir/hinges.dat";
    if($filesize == 0) {
      throw saliweb::frontend::InputValidationError("You have uploaded an empty flexible residues file: $hingefile");
    }
    #convert if needed
    `tr '\r' '\n' < hinges.dat > hinges.dat.tmp`;
    rename("hinges.dat.tmp", "hinges.dat");
    `dos2unix hinges.dat`;
  } else {
    throw saliweb::frontend::InputValidationError("Please upload valid flexible residues file");
  }

  # connectrbs file
  if(length $connectrbsfile > 0) {
    my $upload_filehandle = $q->upload("connectrbsfile");
    open UPLOADFILE, ">$jobdir/connectrbs.dat";
    while ( <$upload_filehandle> ) { print UPLOADFILE; }
    close UPLOADFILE;
    my $filesize = -s "$jobdir/connectrbs.dat";
    if($filesize == 0) {
      throw saliweb::frontend::InputValidationError("You have uploaded an empty rigid bodies connect file: $connectrbsfile");
    }
    #convert if needed
    `tr '\r' '\n' < connectrbs.dat > connectrbs.dat.tmp`;
    rename("connectrbs.dat.tmp", "connectrbs.dat");
    `dos2unix connectrbs.dat`;
  }


  my $input_line = $jobdir . "/input.txt";
  open(INFILE, "> $input_line")
    or throw saliweb::frontend::InternalError("Cannot open $input_line: $!");
  my $cmd = "$pdb_file_name hinges.dat iq.dat";
  if(length $connectrbsfile > 0) { $cmd .= " connectrbs.dat"; }
  else { $cmd .= " -"; }
  $cmd .= " $modelsnumber";
  print INFILE "$cmd\n";
  close(INFILE);

  my $data_file_name = $jobdir . "/data.txt";
  open(DATAFILE, "> $data_file_name")
    or throw saliweb::frontend::InternalError("Cannot open $data_file_name: $!");
  print DATAFILE "$pdb_file_name $hingefile $saxsfile $email $jobname $connectrbsfile $modelsnumber\n";
  close(DATAFILE);

  $job->submit($email);

  my $line = $job->results_url . " " . $pdb_file_name . " " . $hingefile . " " . $saxsfile . " " . $email;
  `echo $line >> ../submit.log`;

  # Inform the user of the job name and results URL
  my $out = $q->p("Your job " . $job->name . " has been submitted.");
  if ($email) {
    $out .= $q->p("You will receive an e-mail with the results link once "
                  . "the job has finished.");
  }
  $out .= $q->p("Results will be found at <a href=\"" . $job->results_url
                . "\">this link</a>.");
  return $out;
}

sub get_results_page {
  my ($self, $job) = @_;
  my $q = $self->cgi;

  my $return = '';
  my $jobname = $job->name;
  my $joburl = $job->results_url;
  my $jobdir = $job->directory;
  my $passwd = $q->param('passwd');

  my @colors2 = ( "[x1a9850]", #green
                  "[xe26261]", # red
                  "[x3288bd]", #blue
                  "[x00FFFF]",
                  "[xA6CEE3]");

  $return .= printCanvas();
  $return .= print_input_data($job);

  my $max_state_number = 5;
  my $gnuplot_string = "<script type=\"text/javascript\"> gnuplot.show_plot(\"jsoutput_3_plot_2\"); </script>";
  for(my $state_number = 1; $state_number <= $max_state_number; $state_number++) {
    my $plotnum = $state_number+1;
    if($state_number != 2 && $state_number != 1) {
      $gnuplot_string .= "<script type=\"text/javascript\"> gnuplot.hide_plot(\"jsoutput_3_plot_$plotnum\"); </script>";
    }
  }
  $return .= "<table align=\"center\"><tr>";
  $return .= "<table align =\"center\"><tr><td align=\"center\"><div  id=\"wrapper2\"><img src=\"" . $job->get_results_file_url("chis.png") . "\" alt='Chi scores' height='250' width='300'/></div></td>\n";

  $return .= "<script type=\"text/javascript\" src=\"" . $job->get_results_file_url("jsoutput.3.js") . "\"></script>\n";
  $return .= "<td><div  id=\"wrapper2\">
<canvas id=\"jsoutput_3\" height='250' width='300' tabindex=\"0\" oncontextmenu=\"return false;\">
<div class='box'><h2>Your browser does not support the HTML 5 canvas element</h2></div>
</canvas>
<div id=\"buttonWrapper\">
<input type=\"button\" id=\"minus\" onclick=\"gnuplot.unzoom();\"/></div></div>
<script type=\"text/javascript\">
  if (window.attachEvent) {window.attachEvent('onload', jsoutput_3);}
else if (window.addEventListener) {window.addEventListener('load', jsoutput_3, false);}
else {document.addEventListener('load', jsoutput_3, false);}
</script>
</td>\n";

  $return .= $gnuplot_string;

  $return .= "<td align=\"center\"><div  id=\"wrapper2\"><img src=\"" . $job->get_results_file_url("hist.png") . "\" alt='Histogram' height='250' width='300'/></div></td>\n";
  $return .= "</tr></table></tr>\n";

  $return .= printJSmol();

  if(-e "$jobdir/ensembles_size_1.txt") {
    $return .= printMultiStateModel($job, "ensembles_size_1.txt", 1, 1, $colors2[0]);
  }

  if(-e "$jobdir/ensembles_size_2.txt") {
    $return .= printMultiStateModel($job, "ensembles_size_2.txt", 2, 1, $colors2[1]);
  }

  if(-e "$jobdir/ensembles_size_3.txt") {
    $return .= printMultiStateModel($job, "ensembles_size_3.txt", 3, 1, $colors2[2]);
  }

  if(-e "$jobdir/ensembles_size_4.txt") {
    $return .= printMultiStateModel($job, "ensembles_size_4.txt", 4, 1, $colors2[3]);
  }

  if(-e "$jobdir/ensembles_size_5.txt") {
    $return .= printMultiStateModel($job, "ensembles_size_5.txt", 5, 1, $colors2[4]);
  }

  $return .= "</table>";

  my $multi_foxs_log_url = $job->get_results_file_url("multifoxs.log");
  $return .= "<table><tr><td><a href=\"". $multi_foxs_log_url . "\"> view log </a> </td> </tr></table>\n";


  return $return;
}

sub printJSmol {
  my $return = "<script type=\"text/javascript\" src=\"/foxs/jsmol2/js/JSmoljQuery.js\"></script>\n";
  $return .= "<script type=\"text/javascript\" src=\"/foxs/jsmol2/js/JSmoljQueryExt.js\"></script>\n";
  $return .= "<script type=\"text/javascript\" src=\"/foxs/jsmol2/js/JSmolCore.js\"></script>\n";
  $return .= "<script type=\"text/javascript\" src=\"/foxs/jsmol2/js/JSmolApplet.js\"></script>\n";
  $return .= "<script type=\"text/javascript\" src=\"/foxs/jsmol2/js/JSmolApi.js\"></script>\n";
  $return .= "<script type=\"text/javascript\" src=\"/foxs/jsmol2/js/j2sjmol.js\"></script>\n";
  $return .= "<script type=\"text/javascript\" src=\"/foxs/jsmol2/js/JSmol.js\"></script>\n";

  $return .= "<script type=\"text/javascript\">\n";
  $return .= "var myInfo1 = {\n";
  $return .= "        height: '98%',\n";
  $return .= "        width: '98%',\n";
  $return .= "        jarFile: \"JmolApplet.jar\",\n";
  $return .= "        jarPath: \"/foxs/jsmol2/../\",\n";
  $return .= "        j2sPath: \"/foxs/jsmol2/j2s/\",\n";
  $return .= "        use: 'HTML5',\n";
  $return .= "        console: \"myJmol1_infodiv\",\n";
  $return .= "        debug: false\n";
  $return .= "};\n";
  $return .= "</script>";

  return $return;
}

sub print_input_data {
  my $job = shift;

  my $filename = "data.txt";
  open FILE, "<$filename" or die "Can't open file: $filename";
  my @dataFile = <FILE>;
  my $dataLine = $dataFile[0];
  chomp($dataLine);
  my @data = split(' ',$dataLine);

  my $pdb_url = $job->get_results_file_url($data[0]);
  my $flexres_url = $job->get_results_file_url("hinges.dat");
  my $profile_url = $job->get_results_file_url("iq.dat");
  my $conformations_number = `cat filenames | wc -l`;
  my $conformations_url = $job->get_results_file_url("conformations.zip");
  my $multi_foxs_url = $job->get_results_file_url("multi_foxs.zip");

  my $return = "<table width=\"90%\"><tr><td>Input protein</td>\n";
  $return .= "<td>Flexible residues</td><td>SAXS profile</td><td>e-mail address</td><td># of conformations</td>\n";
  $return .= "<td colspan=\"2\">Download results</td></tr>\n";

  $return .= "<tr><td><a href=\"". $pdb_url . "\">  $data[0] </a> </td>\n";
  $return .= "<td><a href=\"". $flexres_url . "\"> $data[1] </a> </td>\n";
  $return .= "<td><a href=\"". $profile_url . "\">  $data[2] </a> </td> <td> $data[3] </td>\n";
  $return .= "<td> $conformations_number </td>\n";
  $return .= "<td><a href=\"". $conformations_url . "\">  conformations </a> </td>\n";
  $return .= "<td><a href=\"". $multi_foxs_url . "\"> MultiFoXS output files </a> </td> </tr></table>\n";
  return $return;
}

sub get_foxs_input_fit {
  my ($self, $job) = @_;
  my $q = $self->cgi;

  my $return = '';
  my $jobname = $job->name;
  my $joburl = $job->results_url;
  my $jobdir = $job->directory;
  my $passwd = $q->param('passwd');
  $return .= printCanvas();

  my $gnuplot_string = "<script type=\"text/javascript\"> gnuplot.show_plot(\"jsoutput_1_plot_2\"); </script>";
  my $plotnum = 2;
  $return .= "<table align=\"center\"><tr>";
  $return .= "<script type=\"text/javascript\" src=\"" . $job->get_results_file_url("jsoutput.1.js") . "\"></script>\n";
  $return .= "<td><div  id=\"wrapper2\">
<canvas id=\"jsoutput_1\" height='250' width='300' tabindex=\"0\" oncontextmenu=\"return false;\">
<div class='box'><h2>Your browser does not support the HTML 5 canvas element</h2></div>
</canvas>
<div id=\"buttonWrapper\">
<input type=\"button\" id=\"minus\" onclick=\"gnuplot.unzoom();\"/></div></div>
<script type=\"text/javascript\">
  if (window.attachEvent) {window.attachEvent('onload', jsoutput_1);}
else if (window.addEventListener) {window.addEventListener('load', jsoutput_1, false);}
else {document.addEventListener('load', jsoutput_1, false);}
</script>
</td>\n";

  $return .= $gnuplot_string;
  $return .= "</tr></table></tr>\n";

  $return .= printJSmol();

  `grep -E \"MODEL|ENDMDL|CA| P |HETATM\" jmoltable.pdb > tmpj; mv tmpj jmoltable.pdb`;

  open(JMOLFILE, "<jmoltable.html");
  while(<JMOLFILE>) {
    my $line = $_;
    my $curr_string = "load jmoltable.pdb";
    my $jmoltable_url = $job->get_results_file_url("jmoltable.pdb");
    my $new_string = "load $jmoltable_url";
    $line =~ s/$curr_string/$new_string/;
    $curr_string = "dirname/input_iq.dat";
    my $fit_url = $job->get_results_file_url("input_iq.dat");
    $line =~ s/$curr_string/$fit_url/;
    print $line;
  }
  close(JMOLFILE);
  return $return;
}

sub printCanvas {
  return
    "<script type=\"text/javascript\" src=\"/foxs/gnuplot_js/canvastext.js\"></script>
<script type=\"text/javascript\" src=\"/foxs/gnuplot_js/gnuplot_common.js\"></script>
<script type=\"text/javascript\" src=\"/foxs/gnuplot_js/gnuplot_dashedlines.js\"></script>
<script type=\"text/javascript\" src=\"/foxs/gnuplot_js/gnuplot_mouse.js\"></script>
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


sub printMultiStateModel {
  my ($job, $res_file_name, $state_number, $model_number, $color) = @_;

  my $return = "";

  open(DATA, $res_file_name);
  while(<DATA>) {
    chomp;
    if(index($_, " x1 ") != -1) {
      my @tmp=split('\|',$_);
      if($#tmp>0 and $tmp[0] =~/\d/) {
        my $curr_model_number = int $tmp[0];
        if($curr_model_number == $model_number) {
          my $score = $tmp[1];
          my @c1c2 = split('\(', $tmp[2]);
          my @tmpp = split(',', $c1c2[1]);
          my $c1 = $tmpp[0];
          @c1c2 = split('\)', $tmpp[1]);
          my $c2 = $c1c2[0];
          my $plotnum = $state_number+1;
          $return .= "<tr><th> <b> Best scoring $state_number-state model &chi; = $score  c<sub>1</sub> = $c1  c<sub>2</sub> = $c2\n";
          # print checkbox
          $return .= "<input type='checkbox' id='chbx$plotnum' onchange='func$plotnum()'";
          if($state_number == 2 || $state_number == 1) { $return .= " checked"; }
          $return .= "/>\n";
          $return .= "<script type=\"text/javascript\">\n";
          $return .= "function func$plotnum() {
  if(document.getElementById(\"chbx$plotnum\").checked==true){
     gnuplot.show_plot(\"jsoutput_3_plot_$plotnum\");
   } else {
     gnuplot.hide_plot(\"jsoutput_3_plot_$plotnum\");
   }
  }; </script>\n";
          my $fit_file = "multi_state_model_".$state_number."_1_1.dat";
          $fit_file = $job->get_results_file_url($fit_file);
          $return .= " show/hide <a href = \"$fit_file\"> weighted profile </a> </b> </th></tr><tr><td>";

          $return .= "<table align=\"center\"> <tr>";
          # read and display PDBs
          for(my $i=0; $i<$state_number; $i++) {
            my $curr_state = $i+1;
            my $fileName = "e" . $state_number . "/e" . $model_number ."_" . $i . ".pdb";
            my $newFileName = "e" . $state_number . "_" . $model_number . "_" . $i . ".pdb";
            `grep  -E \"MODEL|ENDMDL|CA| P |HETATM\" $fileName > $newFileName`;
            my $rg = `head -n$curr_state rg$state_number | tail -n1 | awk '{print \$1}'`;
            my $weight = `head -n$curr_state rg$state_number | tail -n1 | awk '{print \$2}'`;
            my $num = $i+1;
            my $fname = $job->get_results_file_url($fileName);
            $return .= "<td><table><tr><th><b><a href=\"$fname\">PDB$num</a> R<sub>g</sub> = $rg w<sub>$num</sub> = $weight</b></th></tr><tr><td>\n";
            $return .= "<div  id=\"wrapper2\">\n";
            $return .= "<script type=\"text/javascript\">\n";
            my $appletName = "myJmol".$state_number."_".$i;
            $return .= "$appletName = Jmol.getApplet(\"$appletName\", myInfo1);\n";
            #$fname = $job->get_results_file_url($newFileName);
            $return .= "Jmol.script($appletName, 'load \"$fname\";backbone OFF; wireframe OFF; spacefill OFF; cartoons; color $color;' );\n";
            $return .= "</script></div></td></tr></table> </td>\n";
          }

          $return .= "</tr> </table> </td></tr>\n";
          last;
        }
      }
    }
  }
  return $return;
}


1;

