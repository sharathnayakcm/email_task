class SeedFlags < ActiveRecord::Migration
  def up
    ['default','Red','Green','Blue','Orange','Yellow'].each do |color|
        Flag.create(:name=> color)
    end
  end

  def down
     Flag.destroy_all
  end
end
