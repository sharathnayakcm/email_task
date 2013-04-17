# To change this template, choose Tools | Templates
# and open the template in the editor.

=begin
class Yamls
  def initialize
    
  end
end
=end

APP_CONFIG = YAML.load_file(File.join(Rails.root, "config", "beehive_configuration.yml"))
TOOLTIP_MESSAGES = YAML.load_file(File.join(Rails.root, "config", "tooltip_messages.yml"))
