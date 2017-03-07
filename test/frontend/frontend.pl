#!/usr/bin/perl -w

use saliweb::Test;
use Test::More 'no_plan';

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
