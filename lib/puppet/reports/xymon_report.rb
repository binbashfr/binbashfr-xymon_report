require 'puppet'
require 'yaml'

Puppet::Reports.register_report(:xymon_report) do

  desc <<-DESC
Xymon reporting
DESC

  def process
    configfile = File.join([File.dirname(Puppet.settings[:config]), "xymon_report.yaml"])
    raise(Puppet::ParseError, "Xymon report config file #{configfile} not readable") unless File.exist?(configfile)
    config = YAML.load_file(configfile)
    xymon_servers   = config[:xymon_servers]
    xymon_test_name = config[:xymon_test_name]
    xymon_bin_path  = config[:xymon_bin_path]
    xymon_test_ttl  = config[:xymon_test_ttl]
    clean_message   = config[:clean_message]

    Puppet.debug "Puppet #{self.kind} run on #{self.host} ended with status #{self.status}"

    if FileTest.exists?(xymon_bin_path)
      xymon_data = ""
      logs = self.logs
      if self.status == 'unchanged'
        xymon_color = "green"
      elsif self.status == 'failed'
        xymon_color = "red"
      else
        xymon_color = "yellow"
      end
      xymon_client = self.host.gsub(".",",")

      logs.each do |log|
        # Clean message from Puppet ?
        if clean_message == "yes"
          # Remove host from source and Puppet tag
          source = log.source.sub(/^\/\/#{self.host}(\/\/|\/Puppet)/,'')
          
          # Remove md5 from message
          if log.message =~ /(.*)'\{md5\}\S+' to '\{md5\}\S+'/
            message = $1
          # Remove md5 from filebucket
          elsif log.message =~ /Filebucketed (.*) to .*/
            message = "Filebucketed #{$1}"
          elsif log.message =~ /defined content/
            message = "defined content"
          else
            message = log.message
          end
        else
          source  = log.source
          message = log.message
        end
        
        if source.empty?
          xymon_data += "#{log.level} - #{message}\n"
        else
          xymon_data += "#{log.level} - #{source} : #{message}\n"
        end
      end
      xymon_servers.each do |server|
        %x{#{xymon_bin_path} #{server} "status+#{xymon_test_ttl} #{xymon_client}.#{xymon_test_name} #{xymon_color} `date` #{self.status}\nLast Puppet #{self.kind} status : #{self.status}\nPuppet exec output :\n#{xymon_data}" }
      end
    end
  end
end
