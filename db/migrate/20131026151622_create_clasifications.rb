class CreateClasifications < ActiveRecord::Migration
  def change
    create_table :clasifications do |t|
      t.string :isla
      t.string :competicion
      t.string :categoria
      t.integer :luchastotales
      t.string :equipo
      t.integer :ganadas
      t.integer :perdidas
      t.integer :empatadas
      t.integer :luchasafavor
      t.integer :luchasencontra
      t.integer :puntos

      t.timestamps
    end
  end
end
