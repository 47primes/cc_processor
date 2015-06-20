ActiveRecord::Schema.define(version: 0) do

  create_table :credit_cards, force: true do |t|
    t.string      :name,    null: false
    t.string      :number,  null: false
    t.integer     :limit,   null: false
    t.integer     :balance, default: 0
    t.timestamps            null: false
  end

end
