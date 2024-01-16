require './site_test.rb'
include SITETEST::TEST

describe SITETEST::TEST do

  describe "ping(host)" do
    it "Should ping IP Addresses" do
      expect(ping("4.2.2.1")).to be true
      expect(ping("8.8.8.8")).to be true
    end
    
    it "Should ping hostnames" do
      expect(ping("www.google.com")).to be true
    end
    
    it "Should fail on un-pingable" do
      expect(ping("169.254.0.200")).to be false
    end
  end
  
  describe 'resolv(host, server = "8.8.8.8")' do
    it 'Should resolv hostnames' do
      expect(resolv('www.summitatsnoqualmie.com')).to eq "137.135.33.14"
    end
    
    it 'Should resolv hostnames with a specific ns' do
      expect(resolv('nwac.com', '4.2.2.1')).to eq "206.188.193.219"
    end
    
    it 'Should fail to resolve unresolvable hosts' do
      expect(resolv('teest.test.lan')).to be nil
    end
  end
  describe "http_code(address)" do
    it "should return http codes for specific sites" do
      expect(http_code('www.google.com')).to eq 200
      expect(http_code('https://store.apple.com/')).to eq 301
      expect(http_code('https://www.google.com')).to eq 200
    end
    it "should return a 0 if a conncetion is reset or no code is returned" do
      expect(http_code('http://1.2.3.4/?0a0fa')).to eq 0
    end
    it "Should respect URI case" do
      expect(http_code('http://ifconfig.me/ip')).to eq 200
      expect(http_code('http://ifconfig.me/IP')).to eq 301
    end

  end
  
  describe 'ssl_code(address, port = 443, path = "/")' do
    it 'should return ssl codes' do
      expect(ssl_code('www.google.com')).to eq 0
      expect(ssl_code('self-signed.badssl.com')).to eq 18
      expect(ssl_code('expired.badssl.com')).to eq 10
    end
  end
  
  describe 'smtp?(address, port)' do
    it 'should return true if 220 and false if not' do
      #expect(smtp?('mail.google.com')).to be true
      expect(smtp?('127.0.0.1')).to be false
    end
  end
  
  describe 'mysql?(address, port)' do
    it 'should return a mysql version as a string' do
      #Run a local mysql server to test
      #mysql?('127.0.0.1').should eq '5.6.16'
    end
    it 'should return nil if no response is returned' do
      expect(mysql?('127.0.0.1')).to be nil
    end
  end
  
  describe 'html(address, host_header, port)' do
    it 'Returns the HTML of the specific page' do
      #To add later
    end
    
    it 'Should timeout and return nil if no response' do
      expect(html('127.0.0.1')).to be nil
    end
  end
end

