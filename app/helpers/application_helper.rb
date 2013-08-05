module ApplicationHelper
  def new_quarter
    @month = Date.today.strftime('%m').to_i
    @quarters = ["4Q", "3Q", "2Q", "1Q"]
    
    if @month <= 3
      @quarters.rotate!(3)
      @quarters.map! do |e| 
        if e == '1Q'
          e + Date.today.strftime('%Y')
        else
          e + (Date.today.strftime('%Y').to_i - 1).to_s
        end  
      end
    elsif 3 < @month && @month <=6
      @quarters.rotate!(2)
      @quarters.map! do |e|
        if e == '2Q' || e == '1Q'
          e + Date.today.strftime('%Y')
        else
          e + (Date.today.strftime('%Y').to_i - 1).to_s
        end
      end
    elsif 6 < @month && @month <= 9
      @quarters.rotate!
      @quarters.map! do |e|
        if e != '4Q'
          e + Date.today.strftime('%Y')
        else
          e + (Date.today.strftime('%Y').to_i - 1).to_s
        end
      end
    elsif 9 < @month
      @quarters.map!{|e| e + Date.today.strftime('%Y')}
    end
  end
end
