require 'net/ping'
require 'resolv'
require 'timeout'
require 'socket'

module SITETEST
  module SITEPARSE
    
    def to_boolean(str)
      str == 'true'
    end
    
    def parse(text)
      icmp_hosts = []
      dns_hosts = []
      http_hosts = []
      ssl_hosts = []
      smtp_hosts = []
      mysql_hosts = []
      html_hosts = []
      tcp_hosts = []
      site_name = 'Missing "Site Name" line'
      
      text.lines do |line|
        line_a = line.downcase.split
        
        unless line_a.empty?
          case line_a[0]
          when "site"
            site_name = line_a[1]
          when "icmp"
              icmp_hosts << {:hostname => line_a[1], :expected_result => to_boolean(line_a[2])}
          when "dns"
            d_host = {:hostname => line_a[1], :expected_result => line_a[2]}
            d_host[:server] = line_a[3].nil? ? nil : line_a[3]
            dns_hosts << d_host
          when "http"
            http_hosts << {:address => line_a[1], :expected_result => line_a[2].to_i}
          when "ssl"
            ssl_hosts << {:address => line_a[1], :expected_result => line_a[2].to_i}
          when "smtp"
            smtp_hosts << {:address => line_a[1], :expected_result => to_boolean(line_a[2])}
          when "mysql"
            mysql_hosts << {:address => line_a[1], :expected_result => line_a[2]}
          when "html"
            host = {}
            line_a = line.split
            host[:address] = line_a[1]
            
            if line_a[2].downcase.include? "host:"
              host[:host_header] = line_a[2].downcase.split("host:").last
              host[:expected_result] = line.match(/\'(.*?)\'/)[1]
            else
              host[:host_header] = nil
              host[:expected_result] = line.match(/\'(.*?)\'/)[1]              
            end
          when "tcp"
            port = line_a[3].nil? ? 80 : line_a[3].to_i
            tcp_hosts << {:hostname => line_a[1], :expected_result => to_boolean(line_a[2]), :port => port}
          else
            #skip line
          end
        end
        
      end
      
      return {:mysql_hosts => mysql_hosts, :html_hosts => html_hosts  ,:icmp_hosts => icmp_hosts, :dns_hosts => dns_hosts, :http_hosts => http_hosts, :ssl_hosts => ssl_hosts, :site_name => site_name, :smtp_hosts => smtp_hosts, :tcp_hosts => tcp_hosts}
      
    end
  end

  module TEST
    def tcping(host, port=80, timeout = 1)
      result = nil
      begin
        Timeout::timeout(timeout) do
          begin
        		socket = TCPSocket.open(host, port)
            result = true
            socket.close
          rescue 
            result = false
          end
        end
      rescue
        result = false
      end
      return result
    end
    
    def ping(host)
      host = Net::Ping::External.new(host)
      host.timeout = 1
      return host.ping?
    end

    def resolv(host, server = "8.8.8.8")
      begin
        resolver = Resolv::DNS.new(:nameserver => [server], :ndots => 1)
        resource = resolver.getresource(host, Resolv::DNS::Resource::IN::A)
        result = resource.address.address.unpack('C4').join(".")
      rescue
        result = nil
      end
      return result
    end

    def http_code(address, timeout = 3)
      unless address[0..3].include? "http"
        address = "http://" + address
      end

      begin
        url = URI.parse(address)
        http = Net::HTTP.new(url.host, url.port)
        http.read_timeout = timeout
        http.open_timeout = timeout
        if address[0..4].include? "https"
          http.use_ssl = true
        end
        response = http.start() { |http| http.get(url) }
        return response.code.to_i
      rescue
        return 0
      end
 
    end

    def ssl_code(address, port = 443, timeout = 3)
      begin
        Timeout::timeout(timeout) do
          ssl_context = OpenSSL::SSL::SSLContext.new
          ssl_context.verify_mode
          tcp_client = TCPSocket.new address, port
          ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client, ssl_context
          ssl_client.connect
          verify_result = ssl_client.verify_result
          ssl_client.close
          return verify_result
        end
      rescue 
        return nil
      end     
    end
    
    def smtp?(address, port = 25)
      code = `ruby -e 'puts "helo test.info"; puts "quit"' | nc -w 3 #{address} #{port}`.split.first.to_i
      code == 220 ? true : false
    end
    
    def mysql?(address, port = 3306)
      version = nil
      text = `echo quit | nc -G 3 #{address} #{port}`
      unless text.empty?
        version = text.unpack('@5A10').first.split("-").first
      end
      return version
    end
    
    def html(address, host_header = nil)
      if host_header
        html = `curl -s -k --connect-timeout 3 -H 'Host: #{host_header}' #{address}`.strip          
      else
        html = `curl -s -k --connect-timeout 3 #{address}`.strip
      end
      return html.empty? ? nil : html
    end
  end
end