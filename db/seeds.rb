require 'csv'


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

a = Assumption.create(value: 0.2, company_id: 1, metric_name: "revs",
                        timespan: 1, time_unit: "y", assumption_type: "growth")
a1 = Assumption.create(value: 0.005, company_id: 1, metric_name: "gross_margin",
                        timespan: 1, time_unit: "q", assumption_type: "growth")
a2 = Assumption.create(value: 0.3, company_id: 1, metric_name: "net_income",
                        timespan: 1, time_unit:"y", assumption_type: "growth")
a3 = Assumption.create(value: 100, company_id: 1, metric_name: "revs",
                        timespan: 5, time_unit: "q", assumption_type: "absolute")

i = IncomeStatement.create(:company_id => 1)
b = BalanceSheet.create(:company_id => 1)
f = CashFlow.create(:company_id => 1)

CSV.foreach("db/income_metrics.csv", headers: true) do |row|
  params = row.to_hash
  params['statementable_id'],params['statementable_type'] = 1, 'IncomeStatement'
  Metric.create(params)
end

CSV.foreach("db/balance_metrics.csv", headers: true) do |row|
  params = row.to_hash
  params['statementable_id'],params['statementable_type'] = 1, 'BalanceSheet'
  Metric.create(params)
end

CSV.foreach("db/cash_metrics.csv", headers: true) do |row|
  params = row.to_hash
  params['statementable_id'],params['statementable_type'] = 1, 'CashFlow'
  Metric.create(params)
end

['Software', 'Semiconductors', 'Retail', 'Homebuilding', 'Restaurant', 'Home Products',
'Transportation', 'Aero & Defense', 'Manufacturing', 'Mining', 'Bank', 'Insurance',
'Media', 'Telecommunications', 'Energy', 'Healthcare', 'Biotech', 'Pharmaceutical'].each do |ind|
  Industry.create(name: ind)
end