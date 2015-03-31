# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
cars = [{
  manufacturer: "Audi",
  design: "Cool",
  style: "racing",
  doors: "5"
},{
  manufacturer: "Renaud",
  design: "Bof",
  style: "tourer",
  doors: "5"
}]
cars.each do |c|
  Car.create(manufacturer: c[:manufacturer], design: c[:design], style: c[:style], doors: c[:doors])
end