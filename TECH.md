# Prerequisites

For this first project, we will assume that:

* you are a competent Linux user
* who is interested in security and privacy
* who is willing to experiment and break things
* who has control of your home environment
* who has control of your home firewall
* who has control of your home DHCP server
* who understands what "static IP address on the local network" means
* who has a spare RaspberryPi, or similar small Linux instance such as
  a container that can have a static IP address exposed on the local
  network

# Installation

## build your system

I'm using a RaspberryPi with Raspbian Lite, but Ubuntu or Debian on
Linux would also work.

## set your system to have a fixed IP address

If you're not using RaspberryPi, this might be different; but I just
checked my local router non-DHCP address space, picked a suitable free
static address, and then followed the process described
[here](https://thepihut.com/blogs/raspberry-pi-tutorials/how-to-give-your-raspberry-pi-a-static-ip-address-update):

```
sudo vi /etc/dhcpcd.conf
```

...and (assuming wifi networking; adjust the interface name if not)
edit or append something like this; see your platform documentation
for correct details.

```
interface wlan0
static ip_address=X.X.X.A/24
static routers=X.X.X.B
static domain_name_servers=X.X.X.C
```

...and then I did `reboot` and checked that the static address was in
place and being used by the RaspberryPi.

Obviously we will be revisiting the value of `domain_name_servers` in
the future.  If you're stuck for a temporary value, use `1.1.1.1` or
`8.8.8.8` for the moment.

## install "tor"

This is easy.  I did:

```
sudo apt install tor
```

...and on Raspbian, at the time of writing, this provides `Tor
0.3.5.8` as shown by `tor -v`.

## configure socks-proxy on tor

Edit `/etc/tor/torrc` and uncomment the line that says:

```
SocksPort 9050 # Default: Bind to localhost:9050 for local connections.
```

## install "dnscrypt-proxy"

[DNSCrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy) is a
"flexible DNS proxy, with support for modern encrypted DNS protocols
such as DNSCrypt v2, DNS-over-HTTPS and Anonymized DNSCrypt"; it's an
interesting tool to mess around with, and even
[references](https://github.com/DNSCrypt/dnscrypt-protocol/blob/master/ANONYMIZED-DNSCRYPT.txt)
some of what we are about to do, in critical terms:

> While the communications themselves are secure, and while the
> stateless nature of the DNSCrypt protocol helps against
> fingerprinting individual devices, DNS server operators can still
> observe client IP addresses.
>
> A common way to prevent this is to use DNSCrypt over Tor or SOCKS
> proxies. However, Tor significantly increases the latency of DNS
> responses. And public SOCKS proxies are difficult to operate, as
> they can easily be abused for purposes unrelated to DNS.

I'm actually okay with this analysis; I consider it to be dated, and
since my work for the past few years has largely consisted of
[disrupting](https://www.facebook.com/notes/protect-the-graph/making-connections-to-facebook-more-secure/1526085754298237/)
[people's](https://open.nytimes.com/https-open-nytimes-com-the-new-york-times-as-a-tor-onion-service-e0d0b67b7482)
[prejudices](https://www.bbc.co.uk/blogs/internet/entries/936e460a-03b3-41db-be96-a6f2f27934e6)
[about](https://tools.ietf.org/html/rfc7686)
[Tor](https://twitter.com/AlecMuffett/status/756451264121167872) and
its [performance and usability](https://github.com/alecmuffett/eotk),
where that document says "Tor significantly increases the latency of
DNS responses", I am coming from the perspective of "can we make it
'good enough for most people'?"  In truth *any* extra "hop" is going
to add latency to my DNS resolutions, and I am willing to trade a
little latency for some extra privacy.

DNSCrypt-proxy is a *huge* package, but has a pretty comprehensive
[wiki](https://github.com/DNSCrypt/dnscrypt-proxy/wiki) to help.

Unfortunately the current (Feb 2020) version of dnscrypt-proxy that is
bundled with Raspbian is too old (`2.0.19`) to be useful; we have to
try to use the precompiled binaries, instead.

Following and abridging the [PiHole instructions](https://github.com/pi-hole/pi-hole/wiki/DNSCrypt-2.0)
```
sudo -i # get to root; all further commands must run as root
cd /opt
wget https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/2.0.39/dnscrypt-proxy-linux_arm-2.0.39.tar.gz
tar xzvf dnscrypt-proxy-linux_arm-2.0.39.tar.gz
rm dnscrypt-proxy-linux_arm-2.0.39.tar.gz
mv linux-arm/ dnscrypt-proxy/
cd dnscrypt-proxy/
echo "# test" > dnscrypt-proxy.toml
chown -R root: ./
./dnscrypt-proxy -service install
./dnscrypt-proxy -service start
```

If you are building on Ubuntu or other platforms, the repositories
(again) seem to be shipping an older version - 2.0.31 on Focal, as of
July 2020; I do not know whether this is recent enough to support
DoHoT, but I can confirm that version 2.0.39 works.  Please let me
know your experiences by logging an `issue` on Github.

## configure dnscrypt-proxy to provide DNS over HTTPS over Tor

One of the things which stops people experimenting with DNS is the
sheer quantity of "magic baggage" that the technology is burdened
with.

A newer bit of magic is
["DNS stamps"](https://dnscrypt.info/stamps-specifications/) - strings
that encode a bunch of otherwise human-readable data, in an
human-unreadable format, for "convenience".

DNSCrypt depends heavily upon stamps, so (for instance) if we want to
use the Cloudflare DNS-over-Onion service as part of our pool, we will
have to synthesise a stamp for it; the process of doing this is
documented in `stampgen.sh` and the result is:

```
sdns://AgcAAAAAAAAAAAA-ZG5zNHRvcnBubGZzMmlmdXoyczJ5ZjNmYzdyZG1zYmhtNnJ3NzVldWozNXBhYzZhcDI1emdxYWQub25pb24KL2Rucy1xdWVyeQ
```

...and we shall add that to the configuration, manually.  Other,
pre-existing "stamps" (and databases thereof) can be imported and used
in the `dnscrypt-proxy` configuration file without much hassle.

To install the configuration:

```
TODO
TODO
TODO
TODO
TODO
TODO
```

## set the server to use itself for resolution

Revisiting `/etc/dhcpcd.conf`, ensure that the DNS configuration line looks something like:

```
static domain_name_servers=X.X.X.C
```

...if you used a temporary, other DNS server.

## reboot to check that everything works

`sudo reboot`
