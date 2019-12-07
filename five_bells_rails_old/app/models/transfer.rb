class Transfer < ApplicationRecord
  belongs_to :sender, foreign_key: 'sender_id', class_name: 'Account'
  belongs_to :receiver, foreign_key: 'receiver_id', class_name: 'Account'
end
