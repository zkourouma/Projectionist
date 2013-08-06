require 'csv'

# class CSV
#   def to_hash
#     Hash[self.collect {|c,r| [c,r]}].symbolize_keys
#   end
# end

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

u = User.new(:email => 'zkourouma@gmail.com')
u.password = 'pass'
u.save

c = Company.create(:name => 'Relative Electric', :headquarters => '7 Psuedo pl, New York, NY',
                  :industry => 'Software', :employees => 3, :user_id => 1)

i = IncomeStatement.create(:company_id => 1)
# b = BalanceSheet.create(:company_id => 1)
# f = CashFlow.create(:company_id => 1)

CSV.foreach("db/income_metrics.csv", headers: true) do |row|
  params = row.to_hash
  params['statementable_id'],params['statementable_type'] = 1, 'IncomeStatement'
  Metric.create(params)
end

# CSV.foreach("db/balance_metrics.csv", headers: true) do |row|
#   b.create_metric(row.to_hash)
# end

# CSV.foreach("db/cash_metrics.csv", headers: true) do |row|
#   f.create_metric(row.to_hash)
# end


Industry.create(name: "Software")
Industry.create(name: "Semiconductors")
Industry.create(name: "Retail")
Industry.create(name: "Homebuilding")
Industry.create(name: "Restaurant")
Industry.create(name: "Home Products")
Industry.create(name: "Transportation")
Industry.create(name: "Aero & Defense")
Industry.create(name: "Industrial Manufacturing")
Industry.create(name: "Metals & Mining")
Industry.create(name: "Bank")
Industry.create(name: "Insurance")
Industry.create(name: "Media")
Industry.create(name: "Telecommunications")
Industry.create(name: "Oil & Gas E&P")
Industry.create(name: "Healthcare")
Industry.create(name: "Biotech")
Industry.create(name: "Pharmaceutical")