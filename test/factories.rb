FactoryGirl.define do

  factory :employee do
    first_name "John"
    last_name "Smith"
    ssn { rand(9 ** 9).to_s.rjust(9,'0') } 
    date_of_birth 20.years.ago
    phone "1234567890"
    role "employee"
    active true
  end

  factory :assignment do
    association :store
    association :employee
    start_date 3.days.ago
    pay_level 1  
  end

  factory :store do
    name "CMU"
    street "5000 Forbes Ave"
    zip "15213"
    phone "4125555555"
    latitude 40.5
    longitude 60.1
    active true
  end
  
  factory :job do
  	name "Sweep"
  	active true
  end
  
  factory :shift do
  	association :assignment
  	date Date.tomorrow
	  start_time 1.hour.ago
  end
  
  factory :user do
  	association :employee
	  email "user@amcreamery.com"
  	password "root99"
	  password_confirmation "root99"
  end

end
