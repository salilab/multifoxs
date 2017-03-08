#!/usr/bin/perl -w

use saliweb::Test;
use Test::More 'no_plan';
use File::Temp;
use Test::Exception;

BEGIN {
    use_ok('multifoxs');
}

my $t = new saliweb::Test('multifoxs');

# Test get_navigation_links
{
    my $self = $t->make_frontend();
    my $links = $self->get_navigation_links();
    isa_ok($links, 'ARRAY', 'navigation links');
    like($links->[0], qr#<a href="http://modbase/top/">MultiFoXS Home</a>#,
         'Index link');
}

# Test get_help_page
{
    my $self = $t->make_frontend();
    $self->{server_name} = "multifoxs";
    my $txt = $self->get_help_page("download");
    $txt = $self->get_help_page("about");
    $txt = $self->get_help_page("contact");
    # Can't assert that the content is OK, because we're probably in the
    # wrong directory to find it
}

# Test get_navigation_lab
{
    my $self = $t->make_frontend();
    my $txt = $self->get_navigation_lab();
    like($txt, qr#<div.*About MultiFoXS.*Sali Lab.*</div>#ms,
         'Navigation');
}

# Test get_project_menu
{
    my $self = $t->make_frontend();
    my $txt = $self->get_project_menu();
    is($txt, "", 'Project menu');
}

# Test get_header
{
    my $self = $t->make_frontend();
    my $txt = $self->get_header();
    like($txt, qr#<div.*modeling with SAXS.*</div>#ms,
         'Header');
}

# Test get_footer
{
    my $self = $t->make_frontend();
    my $txt = $self->get_footer();
    like($txt, qr#If you use MultiFoXS.*<div.*Tainer.*</div>#ms,
         'Footer');
}

# Test get_index_page
{
    my $self = $t->make_frontend();
    my $txt = $self->get_index_page();
    like($txt, qr/Use 100 to test your setup/ms,
         'get_index_page');
}

# Test handle_uploaded_file
{
    my $tmpdir = File::Temp::tempdir(CLEANUP=>1);

    throws_ok { multifoxs::handle_uploaded_file(undef, "$tmpdir/out.file",
                                                "foo") }
              qr/Please upload valid foo/, "handle_uploaded file, missing file";

    # OK if allow_missing=1
    my $out = multifoxs::handle_uploaded_file(undef, "$tmpdir/out.file",
                                              "desc", 1);
    is($out, '', "missing input file, no name");

    ok(open(FH, "> $tmpdir/in.file"), "Open in.file");
    print FH "garbage\n";
    ok(close(FH), "Close in.file");
    ok(open(FH, "< $tmpdir/in.file"), "Open in.file");

    throws_ok { multifoxs::handle_uploaded_file(\*FH, "/foo/bar/out.file", "") }
              qr/Cannot open/, "handle_uploaded file, open failure";

    $out = multifoxs::handle_uploaded_file(\*FH, "$tmpdir/out.file", "desc");
    isnt($out, '', "missing input file, glob name");

    ok(open(FH, "< $tmpdir/out.file"), "Open out.file");
    my $contents = <FH>;
    is($contents, "garbage\n", "Check out.file contents");
    close(FH);
}
