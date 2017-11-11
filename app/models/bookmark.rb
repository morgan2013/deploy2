class Bookmark < ApplicationRecord
  has_many :availabilities

  accepts_nested_attributes_for :availabilities
end
