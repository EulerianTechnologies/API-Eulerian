# API::Eulerian

A Perl module providing a simple interface for the APIs offered by [Eulerian Technologies](https://www.eulerian.com/), including access to the **Eulerian Data Warehouse (EDW)**.

## Features

- **Eulerian Data Warehouse (EDW)** — Query and retrieve analytics data from Eulerian's Data Warehouse via REST or WebSocket peers.
- **Flexible output parsing** — Built-in support for CSV and JSON response formats.
- **Hook system** — Customisable callback hooks to process analysis results as they stream in (start, progress, rows, completion).

## Installation

### From CPAN

```bash
cpanm API::Eulerian
```

### From source

```bash
git clone https://github.com/EulerianTechnologies/API-Eulerian.git
cd API-Eulerian
perl Build.PL
./Build
./Build test
./Build install
```

## Dependencies

- [LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent)
- [Protocol::WebSocket::Client](https://metacpan.org/pod/Protocol::WebSocket::Client)
- [JSON](https://metacpan.org/pod/JSON) / [JSON::Streaming::Reader](https://metacpan.org/pod/JSON::Streaming::Reader)
- [Text::CSV](https://metacpan.org/pod/Text::CSV)
- [File::Slurp](https://metacpan.org/pod/File::Slurp)
- [Encode](https://metacpan.org/pod/Encode)
- [Time::HiRes](https://metacpan.org/pod/Time::HiRes)

## Quick start

Example scripts are available in the `examples/edw/` directory. A typical EDW workflow looks like this:

```perl
use API::Eulerian::EDW::Peer::Rest;
use API::Eulerian::EDW::Hook::Print;

# Create a hook to handle results (or implement your own)
my $hook = API::Eulerian::EDW::Hook::Print->new();

# Create and configure a REST peer
my $peer = API::Eulerian::EDW::Peer::Rest->new();
$peer->setup(
  platform => 'your-platform',
  grid     => 'your-grid',
  token    => 'your-api-token',
  hook     => $hook,
);
```

## Module overview

| Module | Description |
|---|---|
| `API::Eulerian::EDW::Peer::Rest` | REST-based Data Warehouse peer |
| `API::Eulerian::EDW::Peer::Thin` | Lightweight / thin peer |
| `API::Eulerian::EDW::Hook` | Base callback interface for processing results |
| `API::Eulerian::EDW::Hook::Print` | Ready-made hook that prints results to STDOUT |
| `API::Eulerian::EDW::Parser::CSV` | CSV response parser |
| `API::Eulerian::EDW::Parser::JSON` | JSON response parser |
| `API::Eulerian::EDW::Authority` | Authentication and token management |
| `API::Eulerian::EDW::Request` | HTTP request handling |
| `API::Eulerian::EDW::WebSocket` | WebSocket transport layer |

## Documentation

Full POD documentation is available for each module on [MetaCPAN](https://metacpan.org/dist/API-Eulerian). You can also read it locally:

```bash
perldoc API::Eulerian::EDW::Peer
```

## License

This project is licensed under the **GNU General Public License v2.0** (or later). See the [LICENSE](LICENSE) file for details.

## Authors

- Mathieu Jondet — mathieu@eulerian.com
- Xavier Thorillon — xavier@eulerian.com
