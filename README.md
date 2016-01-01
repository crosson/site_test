# site_test
## Why
Using RSPEC to create a functional test for broad and high impact network changes. Allowing you to increase your pereferal knowledge of the impact in your changes. This collection of scripts allows you to quickly monitor dozen's of objects. Consider the following.

This collection of scripts encourages you to create a collection of tests that can quickly be executed and looped. Rather than waiting on a slow NMS to tell you when your change caused an impact somewhere you can create a list of checks to notify you of changes in network behavior in real time.

This makes it easier to monitor load balancer and content switching behavior changes, routing changes, server behavior changes and so on and so forth. The tool encourages engineers to stop the bad habit of manually pinging X hosts during a maintenance and arbitrarily refreshing their icognito web browser to validate web behavior.

A site test is so easy to read that any engineer should be able to immediately interpret your collection of tests. Comment lines are available to narrate your expectations on a maintenance.

Test driven development can and should exist beyond the realm of software development.

```
#site sitename
site Load balancer failover

icmp 10.0.0.3 true
icmp 10.0.0.2 true		# Will ping false during the maintenance but should recover once completed
icmp 10.0.0.1 true		# Vip should always ping true. If it fails ensure that the new active ARP'd for ownership of that VIP

#Site should remain up during the maintenance
http www.mywebsite.com	200
ssl www.mywebsite.com 0	#If the other LB has a bad cert on the VIP this will alert

#Make sure that the DNS VIP still works. Test an internal property agains`
dns service.internal.mywebsite.com 10.10.0.100 10.0.0.15
```

## What
Site Test is just a wrapper around RSPEC. It reads a text file you create and runs a series of tests against it. These are the current tests supported.

* ICMP Ping
* HTTP Codes
* DNS
* SSL
* HTML Parsing*
* SMTP*
* MYSQL*


SMTP, Mysql and HTML parsing are currently making system calls. I plan on replacing these will native ruby solutions soon.

## How

1. Install the site_test gem.
2. symlink test_my.rb and add it to your path.
3. Create a site test. [See the example file](https://github.com/crosson/site_test/blob/master/example.txt)
4. Run your tests.

```
$ test_my mytest.txt 
.........

Finished in 1.38 seconds (files took 0.0926 seconds to load)
9 examples, 0 failures

$ 
```

What it looks like when something fails.
```
$ test_my mytest.txt 
F......F.

Failures:

  1) Mytest check >>  ICMP: Check >>  127.0.0.1 should ping false >> 
     Failure/Error: expect(ping(host[:hostname])).to be expected

       expected false
            got true
     # /Users/crosson/bin/test_my:39:in `block (4 levels) in <main>'

  2) Mytest check >>  HTTP: Check >>  https://store.apple.com/ should result in 200 >> 
     Failure/Error: expect(http_code(address[:address])).to eq address[:expected_result]

       expected: 200
            got: 301

       (compared using ==)
     # /Users/crosson/bin/test_my:59:in `block (4 levels) in <main>'

Finished in 1.56 seconds (files took 0.09239 seconds to load)
9 examples, 2 failures

Failed examples:

rspec /Users/crosson/bin/test_my[1:1:1] # Mytest check >>  ICMP: Check >>  127.0.0.1 should ping false >> 
rspec /Users/crosson/bin/test_my[1:3:2] # Mytest check >>  HTTP: Check >>  https://store.apple.com/ should result in 200 >> 
$
```

The test tells you exactly what it expected and what it recieved instead. 

## Bonus
You get access to all of rspecs flags. Normally your site_test will only output errors after the test is run. Typically you will have this running in a loop during your maintenance but sometimes you want detailed output in realtime.

Try using the --format documentation flag.
```
$ test_my mytest.txt --format documentation

Mytest check >>
  ICMP: Check >>
    127.0.0.1 should ping false >> (FAILED - 1)
    8.8.8.8 should ping true >>
    1.2.3.4 should ping false >>
    www.google.com should ping true >>
  DNS: Check >>
    www.summitatsnoqualmie.com should resolve to 96.31.166.53 >>
    nwac.com should resolve to 67.195.61.46 >>
  HTTP: Check >>
    www.google.com should result in 200 >>
    https://store.apple.com/ should result in 200 >> (FAILED - 2)
  SSL: Check >>
    SSL www.google.com should result in 0 >>

Failures:

  1) Mytest check >>  ICMP: Check >>  127.0.0.1 should ping false >> 
     Failure/Error: expect(ping(host[:hostname])).to be expected

       expected false
            got true
     # /Users/crosson/bin/test_my:39:in `block (4 levels) in <main>'

  2) Mytest check >>  HTTP: Check >>  https://store.apple.com/ should result in 200 >> 
     Failure/Error: expect(http_code(address[:address])).to eq address[:expected_result]

       expected: 200
            got: 301

       (compared using ==)
     # /Users/crosson/bin/test_my:59:in `block (4 levels) in <main>'

Finished in 1.95 seconds (files took 0.09442 seconds to load)
9 examples, 2 failures

Failed examples:

rspec /Users/crosson/bin/test_my[1:1:1] # Mytest check >>  ICMP: Check >>  127.0.0.1 should ping false >> 
rspec /Users/crosson/bin/test_my[1:3:2] # Mytest check >>  HTTP: Check >>  https://store.apple.com/ should result in 200 >> 
$
```

Loop your test using the --format html flag and --out flag. Run a simple HTTP server and see your test results in real time in a web browser.

`test_my mytest.txt --format html --out mytest.html`

[See example output](https://github.com/crosson/site_test/blob/master/mytest.html)
![Alt text](relative/path/to/screenshot.png?raw=true "Example Output")
