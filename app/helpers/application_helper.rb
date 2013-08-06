module ApplicationHelper
  def new_quarter
    @month = Date.today.strftime('%m').to_i
    @quarters = [[4], [3], [2], [1]]
    
    if @month <= 3
      @quarters.rotate!(3)
      @quarters.map! do |e| 
        if e == 1
          e << Date.today.strftime('%Y').to_i
        else
          e << (Date.today.strftime('%Y').to_i - 1)
        end  
      end
    elsif 3 < @month && @month <=6
      @quarters.rotate!(2)
      @quarters.map! do |e|
        if e == 2 || e == 1
          e << Date.today.strftime('%Y').to_i
        else
          e << (Date.today.strftime('%Y').to_i - 1)
        end
      end
    elsif 6 < @month && @month <= 9
      @quarters.rotate!
      @quarters.map! do |e|
        if e != 4
          e << Date.today.strftime('%Y').to_i
        else
          e << (Date.today.strftime('%Y').to_i - 1)
        end
      end
    elsif 9 < @month
      @quarters.map!{|e| e << Date.today.strftime('%Y').to_i}
    end
  end
end
