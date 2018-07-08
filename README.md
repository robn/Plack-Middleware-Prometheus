# NAME

Plack::Middleware::Prometheus - Make Prometheus metrics available to a PSGI app

# SYNOPSIS

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

# DESCRIPTION

XXX WRITEME

- Pass setub\_cb to the middleware constructor
- When called, declare metrics on the passed-in Prometheus::Tiny object
- In the request handler, manipulate those objects through psgix.prometheus
- Point Prometheus at /metrics

# SUPPORT

## Bugs / Feature Requests

Please report any bugs or feature requests through the issue tracker
at [https://github.com/robn/Plack-Middleware-Prometheus/issues](https://github.com/robn/Plack-Middleware-Prometheus/issues).
You will be notified automatically of any progress on your issue.

## Source Code

This is open source software. The code repository is available for
public review and contribution under the terms of the license.

[https://github.com/robn/Plack-Middleware-Prometheus](https://github.com/robn/Plack-Middleware-Prometheus)

    git clone https://github.com/robn/Plack-Middleware-Prometheus.git

# AUTHORS

- Rob N ★ <robn@robn.io>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2018 by Rob N ★

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
