# FAQs

## Why are you only publishing 4 weeks' worth of graphs?

I set this up in early February, and then COVID-19 happened, and I
basically forgot about it; however my server *does* retain slightly
more than 4 weeks worth of logs.

I will try to do better in future.

## Why are you not annotating the DoH providers?

To do so would not seem relevant; after some advanced technical
experimentation with DoH and
[EOTK](https://github.com/alecmuffett/eotk) I simply picked three
ordinary DoH providers and set them up as resolvers in
DNSCrypt-Proxy.

Since the whole point of using Tor is to divorce the server from the
client, I believe that - especially given the automatic load-balancing
of DNSCrypt-Proxy - so long as the results appear consistent it
doesn't really matter who won the race to give the first response; so
why risk being seen to pick favourites?
