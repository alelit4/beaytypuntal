# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131026151622) do

  create_table "calendars", :force => true do |t|
    t.string   "local"
    t.string   "visitante"
    t.integer  "resultadolocal"
    t.integer  "resultadovisitante"
    t.date     "fecha"
    t.string   "hora"
    t.string   "jornada"
    t.integer  "sanciones"
    t.string   "competicion"
    t.string   "isla"
    t.string   "categoria"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "clasifications", :force => true do |t|
    t.string   "isla"
    t.string   "competicion"
    t.string   "categoria"
    t.integer  "luchastotales"
    t.string   "equipo"
    t.integer  "ganadas"
    t.integer  "perdidas"
    t.integer  "empatadas"
    t.integer  "luchasafavor"
    t.integer  "luchasencontra"
    t.integer  "puntos"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

end
