require "lib/init"
class Platforms < Ruport::Report

  renders_with Ruport::Renderer::Grouping
  
  def generate

    table = query "select * from reports"

    not_seen = table.column("user_key").uniq

    table.reduce %w[host_os rubygems_version ruby_version user_key] do |r| 
      not_seen.delete(r.user_key) &&
      !r.user_key.to_s.empty? 
    end

    grouping = Grouping(table, :by => "host_os")

    
    rubygems_versions = Table(%w[platform rubygems_version count])  

    grouping.each do |name,group|
      Grouping(group, :by => "rubygems_version").each do |vname,group|
        rubygems_versions << { "platform"         => name, 
                               "rubygems_version" => vname,
                               "count"            => group.length }
      end
    end

    Grouping(rubygems_versions.sort_rows_by { |r| -r.count }, :by => "platform")
  end

end

if __FILE__ == $0
   Platforms.to_text :show_group_headers => false, :io => STDOUT
end
