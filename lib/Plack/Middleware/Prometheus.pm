package Plack::Middleware::Prometheus;

# ABSTRACT: Make Prometheus metrics available to a PSGI app

use warnings;
use strict;

use parent 'Plack::Middleware';

use Plack::Util::Accessor qw(client setup_cb scrape_cb filename);
use Prometheus::Tiny::Shared 0.011;

sub prepare_app {
  my ($self) = @_;

  $self->client(
    Prometheus::Tiny::Shared->new(
      $self->filename ? (
        filename  => $self->filename,
        init_file => 1,
      ) : (),
    )
  );
  $self->setup_cb->($self->client) if $self->setup_cb;
}

sub call {
  my ($self, $env) = @_;

  if ($env->{PATH_INFO} =~ m{/metrics}) {
    return [ 405, [], [] ] unless $env->{REQUEST_METHOD} eq 'GET';
    $self->scrape_cb->($self->client) if $self->scrape_cb;
    return [ 200, [ 'Content-Type' => 'text/plain' ], [ $self->client->format ] ];
  }

  $env->{'psgix.prometheus'} = $self->client;

  return $self->app->($env);
}

1;

__END__

=encoding UTF-8

=head1 NAME

Plack::Middleware::Prometheus - Make Prometheus metrics available to a PSGI app

=head1 SYNOPSIS

    use Plack::Builder;

    builder {
      enable 'Prometheus',
        setup_cb => sub {
          my ($prom) = @_;
          $prom->declare('requests', type => 'counter', help => 'Number of requests received');
        };
      
      sub {
        my ($env) = @_;
        $env->{'psgix.prometheus'}->inc('requests');
        return [ 200, [], [] ];
      };
    };

=head1 DESCRIPTION

XXX WRITEME

=over 4

=item

Pass setub_cb to the middleware constructor

=item

When called, declare metrics on the passed-in Prometheus::Tiny object

=item

In the request handler, manipulate those objects through psgix.prometheus

=item

Point Prometheus at /metrics

=back

=head1 SUPPORT

=head2 Bugs / Feature Requests

Please report any bugs or feature requests through the issue tracker
at L<https://github.com/robn/Plack-Middleware-Prometheus/issues>.
You will be notified automatically of any progress on your issue.

=head2 Source Code

This is open source software. The code repository is available for
public review and contribution under the terms of the license.

L<https://github.com/robn/Plack-Middleware-Prometheus>

  git clone https://github.com/robn/Plack-Middleware-Prometheus.git

=head1 AUTHORS

=over 4

=item *

Rob N ★ <robn@robn.io>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018 by Rob N ★

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
