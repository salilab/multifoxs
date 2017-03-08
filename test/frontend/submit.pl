# A file handle object that behaves similarly to those returned by CGI's
# upload() method
package TestFh;
use Fcntl;
use overload
    '""' => \&asString;

$FH='fh00000';

sub DESTROY {
    my $self = shift;
    close $self;
}

sub asString {
    my $self = shift;
    # get rid of package name
    (my $i = $$self) =~ s/^\*(\w+::fh\d{5})+//;
    $i =~ s/%(..)/ chr(hex($1)) /eg;
    return $i;
}

sub new {
    my ($pack, $name, $reported_name) = @_;
    if (not defined $reported_name) {
        $reported_name = $name;
    }
    my $fv = ++$FH . $reported_name;
    my $ref = \*{"TestFh::$fv"};
    sysopen($ref, $name, Fcntl::O_RDWR(), 0600) || die "could not open: $!";
    return bless $ref, $pack;
}

package main;

use saliweb::Test;
use Test::More 'no_plan';
use File::Temp;
use Test::Exception;

BEGIN {
    use_ok('multifoxs');
}

my $t = new saliweb::Test('multifoxs');

# Check job submission

sub get_submit_frontend {
    my ($t) = @_;
    my $self = $t->make_frontend();
    my $cgi = $self->cgi;

    $cgi->param('jobname', 'test');
    $cgi->param('modelsnumber', '100');
    return $self;
}

# Check get_submit_page with PDB containing no ATOM records
{
    my $self = get_submit_frontend($t);
    my $tmpdir = File::Temp::tempdir(CLEANUP=>1);
    ok(chdir($tmpdir), "chdir into tempdir");
    ok(mkdir("incoming"), "mkdir incoming");

    my $cgi = $self->cgi;
    ok(open(FH, "> test.pdb"), "Open test.pdb");
    print FH "garbage";
    ok(close(FH), "Close test.pdb");

    $cgi->param("pdbfile", TestFh->new('test.pdb'));

    throws_ok { $self->get_submit_page() }
              saliweb::frontend::InputValidationError,
              "no atoms";
    like($@, qr/PDB file contains no ATOM records/, "exception message");
    chdir('/') # Allow the temporary directory to be deleted
}

# Check get_submit_page with OK PDB
{
    my $self = get_submit_frontend($t);
    my $tmpdir = File::Temp::tempdir(CLEANUP=>1);
    ok(chdir($tmpdir), "chdir into tempdir");
    ok(mkdir("incoming"), "mkdir incoming");

    my $cgi = $self->cgi;
    ok(open(FH, "> test.pdb"), "Open test.pdb");
    print FH "ATOM      2  CA  ALA     1      26.711  14.576   5.091  " .
             "1.00 23.91           C ";
    ok(close(FH), "Close test.pdb");

    $cgi->param("pdbfile", TestFh->new('test.pdb'));

    ok(open(FH, "> test.profile"), "Open test.profile");
    print FH "0.00000    9656627.00000000 2027.89172363";
    ok(close(FH), "Close test.profile");

    $cgi->param("saxsfile", TestFh->new('test.profile'));

    ok(open(FH, "> test.linkers"), "Open test.linkers");
    print FH "189 A";
    ok(close(FH), "Close test.linkers");

    $cgi->param("hingefile", TestFh->new('test.linkers'));

    my $ret = $self->get_submit_page();

    like($ret, qr/Your job testjob has been submitted.*will be found at/ms,
         "submit page HTML");
    chdir('/') # Allow the temporary directory to be deleted
}
