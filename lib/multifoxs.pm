package multifoxs;
use saliweb::frontend;
use strict;

our @ISA = "saliweb::frontend";

sub new {
    return saliweb::frontend::new(@_, @CONFIG@);
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
}

sub get_footer {
    # TODO
}

sub get_index_page {
    # TODO
}

sub get_submit_page {
    # TODO
}

sub get_results_page {
    # TODO
}

1;
