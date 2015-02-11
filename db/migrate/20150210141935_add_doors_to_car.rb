class AddDoorsToCar < ActiveRecord::Migration
  def change
    add_column :cars, :doors, :Integer
  end
end
