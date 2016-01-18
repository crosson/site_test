#!/usr/bin/ruby
#Driver for site_test
if ARGV[0]
  $filename = File.read(ARGV[0])
  ARGV[0] = nil
  ARGV.compact!
  
  require 'rubygems'  
  require 'site_test'
  require 'rspec/autorun'
  include SITETEST::TEST
  include SITETEST::SITEPARSE
else
  puts "Missing Filename"
end

RSpec.configure do |config|
  config.full_backtrace=false
  path = File.expand_path(__FILE__)
  config.backtrace_inclusion_patterns << /#{path}/
end

parsed_objects = parse($filename)
$icmp_checks = parsed_objects[:icmp_hosts]
$dns_checks = parsed_objects[:dns_hosts]
$http_checks = parsed_objects[:http_hosts]
$ssl_checks = parsed_objects[:ssl_hosts]
$smtp_checks = parsed_objects[:smtp_hosts]
$site_name = parsed_objects[:site_name]
$mysql_checks = parsed_objects[:mysql_hosts]
$html_checks = parsed_objects[:html_hosts]
$tcp_checks = parsed_objects[:tcp_hosts]


describe "#{$site_name.capitalize} check >> " do
  describe "ICMP: Check >> " do 
    $icmp_checks.each do |host|
      it "#{host[:hostname]} should ping #{host[:expected_result]} >> " do
        expected = host[:expected_result] ? true : false
        expect(ping(host[:hostname])).to be expected
      end
    end
  end

  describe "DNS: Check >> " do
    $dns_checks.each do |host|
      it "#{host[:hostname]} should resolve to #{host[:expected_result]} >> " do
        unless host[:server].nil?
          expect(resolv(host[:hostname], host[:server])).to eq host[:expected_result]
        else
          expect(resolv(host[:hostname])).to eq host[:expected_result]          
        end
      end
    end
  end

  describe "HTTP: Check >> " do
    $http_checks.each do |address|
      it "#{address[:address]} should result in #{address[:expected_result]} >> " do
        expect(http_code(address[:address])).to eq address[:expected_result]
      end
    end
  end
  
  
  describe "SSL: Check >> " do
    $ssl_checks.each do |address|
      it "SSL #{address[:address]} should result in #{address[:expected_result]} >> " do
        expect(ssl_code(address[:address])).to eq address[:expected_result]
      end
    end
  end
  
  describe "SMTP: Check >> " do
    $smtp_checks.each do |address|
      it "SMTP #{address[:address]} should result in #{address[:expected_result]} >> " do
        expect(smtp?(address[:address])).to eq address[:expected_result]
      end
    end
  end
  
  describe "MYSQL: Check >> " do
    $mysql_checks.each do |address|
      it "MYSQL #{address[:address]} should result in #{address[:expected_result]} >> " do
        expect(mysql?(address[:address])).to eq address[:expected_result]
      end
    end
  end
  
  describe "HTML: Check >> " do
    $html_checks.each do |address|
      it "HTML #{address[:address]} should result in #{address[:expected_result]} >> " do
        if address[:host_header]
          expect(html(address[:address], address[:host_header])).to eq address[:expected_result]          
        else
          expect(html(address[:address])).to eq address[:expected_result]
        end
      end
    end
  end
  describe "TCP: Check >> " do 
    $tcp_checks.each do |host|
      it "#{host[:hostname]}:#{host[:port]} should tcping #{host[:expected_result]} >> " do
        expected = host[:expected_result]
        expect(tcping(host[:hostname], host[:port])).to be expected
      end
    end
  end
end
