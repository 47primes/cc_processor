ActiveRecord::Schema.define(version: 0) do

  create_table :card_holders, force: true do |t|
    t.string      :name,  null: false
    t.timestamps          null: false
  end

  create_table :credit_cards, force: true do |t|
    t.integer     :card_holder_id,  null: false
    t.string      :number,          null: false
    t.integer     :limit,           null: false
    t.integer     :balance,         default: 0
    t.timestamps                    null: false
  end

end
