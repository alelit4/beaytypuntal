class CreateCalendars < ActiveRecord::Migration
  def change
    create_table :calendars do |t|
      t.string :local
      t.string :visitante
      t.integer :resultadolocal
      t.integer :resultadovisitante
      t.date :fecha
      t.string :hora
      t.string :jornada
      t.integer :sanciones
      t.string :competicion
      t.string :isla
      t.string :categoria

      t.timestamps
    end
  end
end
