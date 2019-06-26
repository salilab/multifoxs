#!/usr/bin/perl -w

use saliweb::Test;
use Test::More 'no_plan';
use Test::Exception;
use File::Temp qw(tempdir);

BEGIN {
    use_ok('multifoxs');
    use_ok('saliweb::frontend');
}

my $t = new saliweb::Test('multifoxs');

# Check results page

# Check get_results_page
{
    my $frontend = $t->make_frontend();
    my $tmpdir = tempdir(CLEANUP=>1);
    ok(chdir($tmpdir), "chdir into tempdir");
    my $job = new saliweb::frontend::CompletedJob($frontend,
                        {name=>'testjob', passwd=>'foo', directory=>$tmpdir,
                         archive_time=>'2009-01-01 08:45:00'});

    ok(open(FH, "> data.txt"), "Open data.txt");
    print FH "testpdb testflexres testprofile test4\n";
    ok(close(FH), "Close data.txt");

    ok(open(FH, "> filenames"), "Open filenames");
    print FH "file1\nfile2\nfile3\n";
    ok(close(FH), "Close filenames");

    my $ret = $frontend->get_results_page($job);
    like($ret, '/canvastext\.js.*'.
               'results.cgi\/testjob\/testpdb\?passwd=foo.*' .
               'results.cgi\/testjob\/hinges\.dat\?passwd=foo.*' .
               'results.cgi\/testjob\/iq\.dat\?passwd=foo.*' .
               'results.cgi\/testjob\/conformations\.zip\?passwd=foo.*' .
               'Your browser does not support the HTML 5 canvas.*' .
               'gnuplot\.show_plot\(\"jsoutput_3_plot_2\"\).*' .
               'foxs\/jsmol2\/js\/JSmol\.js.*' .
               'view log/ms', 'display ok job');

    ok(open(FH, "> ensembles_size_1.txt"), "Open ensembles");
    print FH <<END;
1 |  2.39 | x1 2.39 (0.99, 2.97)
    0   | 1.000 (1.000, 1.000) | nodes27_m44.pdb.dat (0.004)
2 |  2.60 | x1 2.60 (0.99, 3.26)
    1   | 1.000 (1.000, 1.000) | nodes49_m15.pdb.dat (0.004)
3 |  2.69 | x1 2.69 (0.99, 4.00)
    2   | 1.000 (1.000, 1.000) | nodes23_m27.pdb.dat (0.004)
4 |  3.10 | x1 3.10 (1.02, 4.00)
    4   | 1.000 (1.000, 1.000) | nodes94_m27.pdb.dat (0.004)
5 |  3.26 | x1 3.26 (0.99, 4.00)
    7   | 1.000 (1.000, 1.000) | nodes50_m4.pdb.dat (0.004)
END
    ok(close(FH), "Close ensembles");

    ok(open(FH, "> rg1"), "Open rg1");
    print FH "20.6664 1\n19.8629 1\n20.5571 1\n19.8411 1\n";
    ok(close(FH), "Close rg1");

    ok(mkdir('e1'));
    ok(open(FH, "> e1/e1_0.pdb"), "Open PDB");
    print FH "\n";
    ok(close(FH), "Close PDB");

    $ret = $frontend->get_results_page($job);
    like($ret, '/Best scoring 1-state model.*' .
               'gnuplot\.show_plot\(\"jsoutput_3_plot_2\"\);.*' .
               'testjob\/multi_state_model_1_1_1\.fit\?passwd=foo.*' .
               'testjob\/e1\/e1_0\.pdb\?passwd=foo.*' .
               'backbone OFF; wireframe OFF; spacefill OFF;/ms',
         "display ok job with ensemble size 1");

    chdir("/");
}

# Check get_file_mime_type
{
    my $frontend = $t->make_frontend();
    is($frontend->get_file_mime_type('jsoutput.3.js'), 'text/javascript',
       "get_file_mime_type, javascript");
    is($frontend->get_file_mime_type('foo.png'), 'image/png',
       "get_file_mime_type, image file");
    is($frontend->get_file_mime_type('foo.log'), 'text/plain',
       "get_file_mime_type, log file");
}
